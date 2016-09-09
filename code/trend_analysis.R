

a1 <- read.csv("data3.data")
colnames(a1)<-c("id","2009","2010","2011","2012","2013","2014","2015","Count","average")
a <-a1[,-c(1,10,9)]

#k<-head(a)
future<-c()

for( i in 1:nrow(a))
{
    temp<-a[i,]
  series <- ts(temp,start=c(2009))
  forecasts<- HoltWinters(series, beta=FALSE, gamma=FALSE)
  future[i]<-as.numeric(forecasts$coefficients)
}

a1[,"furture"]<-future


j1<-c()

p1<-a[952,]
p2<-a[951,]
j1<-as.list(p1)
j2<-as.list(p2)


t1<-ts(j1,frequency = 1,start=c(2009,1))
plot.ts(t1)

t2<-ts(j2,frequency = 1,start=c(2009,1))
lines(t2)

#x=forecasts.holtwinters(model,h=8)
#plot.forecasts(x)
#forecast package

#write.csv(a,"out1.data")
