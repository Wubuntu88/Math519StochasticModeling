'This matrix represents the distances from point to point.
It is massively sparse even though it is not a sparse matrix'
distMtrx = array(0, dim = c(4, 4, 4, 4))
# first initialize all rows
#row 1
distMtrx[1, 1, 1, 2] = 1
distMtrx[1, 2, 1, 3] = 5
distMtrx[1, 3, 1, 4] = 2
#row 2
distMtrx[2, 1, 2, 2] = 7
distMtrx[2, 2, 2, 3] = 1
distMtrx[2, 3, 2, 4] = 3 
#row 3
distMtrx[3, 1, 3, 2] = 5
distMtrx[3, 2, 3, 3] = 2
distMtrx[3, 3, 3, 4] = 2
#row 4
distMtrx[4, 1, 4, 2] = 2
distMtrx[4, 2, 4, 3] = 4
distMtrx[4, 3, 4, 4] = 10^9

#col 1
distMtrx[1, 1, 2, 1] = 0
distMtrx[2, 1, 3, 1] = 3
distMtrx[3, 1, 4, 1] = 4
#col 2
distMtrx[1, 2, 2, 2] = 4
distMtrx[2, 2, 3, 2] = 2
distMtrx[3, 2, 4, 2] = 2
#col 3
distMtrx[1, 3, 2, 3] = 1
distMtrx[2, 3, 3, 3] = 4
distMtrx[3, 3, 4, 3] = 8
#col 4
distMtrx[1, 4, 2, 4] = 3
distMtrx[2, 4, 3, 4] = 5
distMtrx[3, 4, 4, 4] = 2

'This matrix represents the \'vertices\' in the original diagram.
A number at a point represents the cost to the
destination through the best path.'
myMatrix = matrix(nrow = 4, ncol = 4, 0)

goRightSuccessProbability = 0.8
goRightFailureProbability = 1.0 - goRightSuccessProbability

goDownSuccessProbability = 0.9
goDownFailureProbability = 1.0 - goDownSuccessProbability

fill = function(mat) {
  num_rows = dim(mat)[1]
  num_cols = dim(mat)[2]
  for(r in num_rows:1) {
    for(c in num_cols:1) {
      if(r == num_rows && c == num_cols) {
        next
      }else {
        goRightPureCost = 9999
        goDownPureCost = 9999
        
        if(c < num_cols) {
          goRightPureCost = mat[r,c + 1] + distMtrx[r, c, r, c + 1]
        }
        
        if(r < num_rows) {
          goDownPureCost = mat[r + 1, c] + distMtrx[r, c, r + 1, c]
        }
        
        goRightExpectedCost = goRightSuccessProbability * goRightPureCost +
                              goRightFailureProbability * goDownPureCost
        
        goDownExpectedCost =  goDownSuccessProbability * goDownPureCost +
                              goDownFailureProbability * goRightPureCost
        
        
        if(goRightExpectedCost < goDownExpectedCost) {
          mat[r, c] = goRightExpectedCost
        }else {
          mat[r, c] = goDownExpectedCost
        }
      }
    }
  }
  return(mat)
}
newMtrx = fill(mat = myMatrix)
print(newMtrx)

r = 1
c = 1
num_rows = dim(newMtrx)[1]
num_cols = dim(newMtrx)[2]
while(!(r == num_rows && c == num_cols)) {
  goRightPureCost = 9999
  goDownPureCost = 9999
  
  if(c < num_cols) {
    goRightPureCost = newMtrx[r,c + 1] + distMtrx[r, c, r, c + 1]
  }
  
  if(r < num_rows) {
    goDownPureCost = newMtrx[r + 1, c] + distMtrx[r, c, r + 1, c] 
  }
  
  goRightExpectedCost = goRightSuccessProbability * goRightPureCost +
                        goRightFailureProbability * goDownPureCost
  
  goDownExpectedCost =  goDownSuccessProbability * goDownPureCost +
                        goDownFailureProbability * goRightPureCost
  
  
  #decide which way to go based on the minimum cost of the two options
  if(goRightExpectedCost < goDownExpectedCost) {
    print("right")
    c = c + 1
  }else {
    print("down")
    r = r + 1
  }
}





