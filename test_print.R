frame <- data.frame(matrix(c(1,2,3,4), nrow=2), 
                    row.names=c("A", "B"), 
                    col.names = c("1","2")
)
print("3")
print(3)
#remember R vectors are 1 indexed...
sprintf("%i",dim(frame)[1])
print(sprintf("%i",3))
