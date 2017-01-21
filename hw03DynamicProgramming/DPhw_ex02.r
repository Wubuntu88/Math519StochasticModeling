'This matrix represents the distances from point to point.
It is massively sparse even though it is not a sparse matrix'
distMtrx = array(9999, dim = c(4, 4, 4, 4))
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
distMtrx[4, 3, 4, 4] = 1

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
A number at a point represents the worst case edge that one must
pass over that is through the best path.'
myMatrix = matrix(nrow = 4, ncol = 4, 0)

fill = function(mat) {
  num_rows = dim(mat)[1]
  num_cols = dim(mat)[2]
  for(r in num_rows:1) {
    for(c in num_cols:1) {
      if(r == num_rows && c == num_cols) {
        next
      }else {
        rightCost = 9999
        if(c < num_cols) {
          rightCost = max(mat[r,c + 1], distMtrx[r, c, r, c + 1])
        }
        downCost = 9999
        if(r < num_rows) {
          downCost = max(mat[r + 1, c], distMtrx[r, c, r + 1, c])
        }
        
        if(rightCost < downCost) {
          mat[r, c] = rightCost
        }else {
          mat[r, c] = downCost
        }
      }
    }
  }
  return(mat)
}

print("matrix of cost at vertices:")
newMtrx = fill(mat = myMatrix)
print(newMtrx)

r = 1
c = 1
num_rows = dim(newMtrx)[1]
num_cols = dim(newMtrx)[2]
while(!(r == num_rows && c == num_cols)) {
  rightCost = 9999
  if(c < num_cols) {
    rightCost = max( distMtrx[r, c, r, c + 1], newMtrx[r, c + 1] )
  }
  downCost = 9999
  if(r < num_rows) {
    downCost = max( distMtrx[r, c, r + 1, c], newMtrx[r + 1, c] )
  }

  #decide which way to go based on the minimum cost of the two options
  if(rightCost < downCost) {
    print("right")
    c = c + 1
  }else if(downCost < rightCost) {
    print("down")
    r = r + 1
  }else{
    randomNumber = runif(1)
    if(randomNumber < 0.5) {
      print("right-random")
      c = c + 1
    }else {
      print("down-random")
      r = r + 1
    }
  }
}












