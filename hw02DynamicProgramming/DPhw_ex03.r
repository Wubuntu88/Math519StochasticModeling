distMtrx = array(0.0, dim = c(4, 4, 4, 4))

# first initialize all rows
#row 1
distMtrx[1, 1, 1, 2] = .99
distMtrx[1, 2, 1, 3] = .95
distMtrx[1, 3, 1, 4] = .98
#row 2
distMtrx[2, 1, 2, 2] = .93
distMtrx[2, 2, 2, 3] = .99
distMtrx[2, 3, 2, 4] = .97
#row 3
distMtrx[3, 1, 3, 2] = .95
distMtrx[3, 2, 3, 3] = .98
distMtrx[3, 3, 3, 4] = .98
#row 4
distMtrx[4, 1, 4, 2] = .98
distMtrx[4, 2, 4, 3] = .96
distMtrx[4, 3, 4, 4] = .99

#col 1
distMtrx[1, 1, 2, 1] = 1.0
distMtrx[2, 1, 3, 1] = .97
distMtrx[3, 1, 4, 1] = .96
#col 2
distMtrx[1, 2, 2, 2] = .96
distMtrx[2, 2, 3, 2] = .98
distMtrx[3, 2, 4, 2] = .98
#col 3
distMtrx[1, 3, 2, 3] = .99
distMtrx[2, 3, 3, 3] = .97
distMtrx[3, 3, 4, 3] = .92
#col 4
distMtrx[1, 4, 2, 4] = .97
distMtrx[2, 4, 3, 4] = .95
distMtrx[3, 4, 4, 4] = .98

'This matrix represents the \'vertices\' in the original diagram.
A number at a point represents the probability of success to the 
destination through the best path.'
myMatrix = matrix(nrow = 4, ncol = 4, 1)

fill = function(mat) {
  num_rows = dim(mat)[1]
  num_cols = dim(mat)[2]
  for(r in num_rows:1) {
    for(c in num_cols:1) {
      if(r == num_rows && c == num_cols) {
        next
      }else {
        rightSuccessProbability = 0.0
        if(c < num_cols) {
          rightSuccessProbability = mat[r,c + 1] * distMtrx[r, c, r, c + 1]
        }
        downSuccessProbability = 0.0
        if(r < num_rows) {
          downSuccessProbability = mat[r + 1, c] * distMtrx[r, c, r + 1, c]
        }
        
        if(rightSuccessProbability > downSuccessProbability) {
          mat[r, c] = rightSuccessProbability
        }else {
          mat[r, c] = downSuccessProbability
        }
      }
    }
  }
  return(mat)
}
print("matrix of probability of success at vertices to destination:")
newMtrx = fill(mat = myMatrix)
print(newMtrx)

r = 1
c = 1
num_rows = dim(newMtrx)[1]
num_cols = dim(newMtrx)[2]
while(!(r == num_rows && c == num_cols)) {
  rightSuccessProbability = 0.0
  if(c < num_cols) {
    rightSuccessProbability = distMtrx[r, c, r, c + 1] * newMtrx[r, c + 1]
  }
  downCost = 0.0
  if(r < num_rows) {
    downCost = distMtrx[r, c, r + 1, c] * newMtrx[r + 1, c]
  }

  #decide which way to go based on the minimum cost of the two options
  if(rightSuccessProbability > downCost) {
    print("right")
    c = c + 1
  }else {
    print("down")
    r = r + 1
  }
}





