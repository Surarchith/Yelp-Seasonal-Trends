echo  "Welcome"

echo "\nsending files into hdfs from local"
echo "\n--Please Wait---"
hdfs dfs -put business.json
hdfs dfs -put user.json
hdfs dfs -put tip.json
hdfs dfs -put checkin.json
hdfs dfs -put review.json

echo "\n\n--done--"

echo  "Connecting into the spark shell"
echo "-----------------------"

spark-shell


println("Loading Data :");
println("————————");


val business = sqlContext.read.json("business.json");

val review = sqlContext.read.json("review.json");

val  checkin = sqlContext.read.json("checkin.json");

review.registerTempTable("review")

business.registerTempTable("business")

checkin.registerTempTable("checkin")

println("initial tables :");

business.show

review.show

checkin.show

println("Get input for time series analysis :")
println("SPRING  :")


val spring = sqlContext.sql("SELECT business.business_id, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=3 AND MONTH(date) <=5)  AND (YEAR(date) >=2009)");

spring.registerTempTable("spring");

val spring1 = sqlContext.sql("select business_id, case when year = 2009 then AVG(stars) else 0 end  , case when year = 2010 then AVG(stars) else 0 end , case when year = 2011 then AVG(stars) else 0 end , case when year = 2012 then AVG(stars) else 0 end , case when year = 2013 then AVG(stars) else 0 end , case when year = 2014 then AVG(stars) else 0 end , case when year = 2015 then AVG(stars) else 0  end  from spring group by business_id, year");


val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val springRenamed = spring1.toDF(newNames: _*)

springRenamed.registerTempTable("springRenamed")

val springFin = sqlContext.sql("select business_id , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from springRenamed group by business_id");

val springRenamed = springFin.toDF(newNames: _*)

springRenamed.registerTempTable("springRenamed")

val spring2 = sqlContext.sql("select business_id,count(stars) as count from spring group by business_id");

spring2.registerTempTable("spring2")

val springFin = sqlContext.sql("select springRenamed.business_id,year1,year2,year3,year4,year5,year6,year7,count from springRenamed, spring2 where spring2.business_id == springRenamed.business_id");

springFin.registerTempTable("springFin")

val springRes = sqlContext.sql("select business_id, case when year1 = 0 then 2.5 else sum(year1) end  , case when year2 = 0 then 2.5 else sum(year2) end , case when year3 = 0 then 2.5 else sum(year3) end , case when year4 = 0 then 2.5 else sum(year4) end , case when year5 = 0 then 2.5 else sum(year5) end , case when year6 = 0 then 2.5 else sum(year6) end , case when year7 = 0 then 2.5 else sum(year7) end,sum(count)  from springFin group by business_id,year1,year2,year3,year4,year5,year6,year7,count");

val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7","count")

val springRenamed = springRes.toDF(newNames: _*)

springRenamed.registerTempTable("springRenamed")


val springAvg = sqlContext.sql("select *, (year1+year2+year3+year4+year5+year6+year7)/7 as average from springRenamed ");

springAvg.registerTempTable("springAvg")

springAvg.show



println("SUMMER")

val summer = sqlContext.sql("SELECT business.business_id, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=6 AND MONTH(date) <=8)  AND (YEAR(date) >=2009)");

summer.registerTempTable("summer");

val summer1 = sqlContext.sql("select business_id, case when year = 2009 then AVG(stars) else 0 end  , case when year = 2010 then AVG(stars) else 0 end , case when year = 2011 then AVG(stars) else 0 end , case when year = 2012 then AVG(stars) else 0 end , case when year = 2013 then AVG(stars) else 0 end , case when year = 2014 then AVG(stars) else 0 end , case when year = 2015 then AVG(stars) else 0  end  from summer group by business_id, year");


val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val summerRenamed = summer1.toDF(newNames: _*)

summerRenamed.registerTempTable("summerRenamed")

val summerFin = sqlContext.sql("select business_id , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from summerRenamed group by business_id");

val summerRenamed = summerFin.toDF(newNames: _*)

summerRenamed.registerTempTable("summerRenamed")

val summer2 = sqlContext.sql("select business_id,count(stars) as count from summer group by business_id");

summer2.registerTempTable("summer2")

val summerFin = sqlContext.sql("select summerRenamed.business_id,year1,year2,year3,year4,year5,year6,year7,count from summerRenamed, summer2 where summer2.business_id == summerRenamed.business_id");

summerFin.registerTempTable("summerFin")

val summerRes = sqlContext.sql("select business_id, case when year1 = 0 then 2.5 else sum(year1) end  , case when year2 = 0 then 2.5 else sum(year2) end , case when year3 = 0 then 2.5 else sum(year3) end , case when year4 = 0 then 2.5 else sum(year4) end , case when year5 = 0 then 2.5 else sum(year5) end , case when year6 = 0 then 2.5 else sum(year6) end , case when year7 = 0 then 2.5 else sum(year7) end,sum(count)  from summerFin group by business_id,year1,year2,year3,year4,year5,year6,year7,count");

val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7","count")

val summerRenamed = summerRes.toDF(newNames: _*)

summerRenamed.registerTempTable("summerRenamed")


val summerAvg = sqlContext.sql("select *, (year1+year2+year3+year4+year5+year6+year7)/7 as average from summerRenamed ");

summerFin.registerTempTable("summerAvg")

summerAvg.show




println("Autumn") 


val autumn = sqlContext.sql("SELECT business.business_id, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=9 AND MONTH(date) <=11)  AND (YEAR(date) >=2009)");

autumn.registerTempTable("autumn");

val autumn1 = sqlContext.sql("select business_id, case when year = 2009 then AVG(stars) else 0 end  , case when year = 2010 then AVG(stars) else 0 end , case when year = 2011 then AVG(stars) else 0 end , case when year = 2012 then AVG(stars) else 0 end , case when year = 2013 then AVG(stars) else 0 end , case when year = 2014 then AVG(stars) else 0 end , case when year = 2015 then AVG(stars) else 0  end  from autumn group by business_id, year");


val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val autumnRenamed = autumn1.toDF(newNames: _*)

autumnRenamed.registerTempTable("autumnRenamed")

val autumnFin = sqlContext.sql("select business_id , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from autumnRenamed group by business_id");

val autumnRenamed = autumnFin.toDF(newNames: _*)

autumnRenamed.registerTempTable("autumnRenamed")

val autumn2 = sqlContext.sql("select business_id,count(stars) as count from autumn group by business_id");

autumn2.registerTempTable("autumn2")

val autumnFin = sqlContext.sql("select autumnRenamed.business_id,year1,year2,year3,year4,year5,year6,year7,count from autumnRenamed, autumn2 where autumn2.business_id == autumnRenamed.business_id");

autumnFin.registerTempTable("autumnFin")

val autumnRes = sqlContext.sql("select business_id, case when year1 = 0 then 2.5 else sum(year1) end  , case when year2 = 0 then 2.5 else sum(year2) end , case when year3 = 0 then 2.5 else sum(year3) end , case when year4 = 0 then 2.5 else sum(year4) end , case when year5 = 0 then 2.5 else sum(year5) end , case when year6 = 0 then 2.5 else sum(year6) end , case when year7 = 0 then 2.5 else sum(year7) end,sum(count)  from autumnFin group by business_id,year1,year2,year3,year4,year5,year6,year7,count");

val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7","count")

val autumnRenamed = autumnRes.toDF(newNames: _*)


autumnRenamed.registerTempTable("autumnRenamed")


val autumnAvg = sqlContext.sql("select *, (year1+year2+year3+year4+year5+year6+year7)/7 as average from autumnRenamed ");

autumnAvg.registerTempTable("autumnAvg")

autumnAvg.show




println("Winter: ")


val winter = sqlContext.sql("SELECT business.business_id, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=11 OR MONTH(date) <=2)  AND (YEAR(date) >=2009)");

winter.registerTempTable("winter");

val winter1 = sqlContext.sql("select business_id, case when year = 2009 then AVG(stars) else 0 end  , case when year = 2010 then AVG(stars) else 0 end , case when year = 2011 then AVG(stars) else 0 end , case when year = 2012 then AVG(stars) else 0 end , case when year = 2013 then AVG(stars) else 0 end , case when year = 2014 then AVG(stars) else 0 end , case when year = 2015 then AVG(stars) else 0  end  from winter group by business_id, year");


val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val winterRenamed = winter1.toDF(newNames: _*)

winterRenamed.registerTempTable("winterRenamed")

val winterFin = sqlContext.sql("select business_id , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from winterRenamed group by business_id");

val winterRenamed = winterFin.toDF(newNames: _*)

winterRenamed.registerTempTable("winterRenamed")

val winter2 = sqlContext.sql("select business_id,count(stars) as count from winter group by business_id");

winter2.registerTempTable("winter2")

val winterFin = sqlContext.sql("select winterRenamed.business_id,year1,year2,year3,year4,year5,year6,year7,count from winterRenamed, winter2 where winter2.business_id == winterRenamed.business_id");

winterFin.registerTempTable("winterFin")

val winterRes = sqlContext.sql("select business_id, case when year1 = 0 then 2.5 else sum(year1) end  , case when year2 = 0 then 2.5 else sum(year2) end , case when year3 = 0 then 2.5 else sum(year3) end , case when year4 = 0 then 2.5 else sum(year4) end , case when year5 = 0 then 2.5 else sum(year5) end , case when year6 = 0 then 2.5 else sum(year6) end , case when year7 = 0 then 2.5 else sum(year7) end,sum(count)  from winterFin group by business_id,year1,year2,year3,year4,year5,year6,year7,count");

val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7","count")

val winterRenamed = winterRes.toDF(newNames: _*)


winterRenamed.registerTempTable("winterRenamed")


val winterAvg = sqlContext.sql("select *, (year1+year2+year3+year4+year5+year6+year7)/7 as average from winterRenamed ");

winterAvg.registerTempTable("winterAvg")



println("spring based on count :")


val spring = sqlContext.sql("SELECT business.business_id, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=3 AND MONTH(date) <=5)  AND (YEAR(date) >=2009)");

spring.registerTempTable("spring");

val spring1 = sqlContext.sql("select business_id, case when year = 2009 then COUNT(stars) else 0 end  , case when year = 2010 then COUNT(stars) else 0 end , case when year = 2011 then COUNT(stars) else 0 end , case when year = 2012 then COUNT(stars) else 0 end , case when year = 2013 then COUNT(stars) else 0 end , case when year = 2014 then COUNT(stars) else 0 end , case when year = 2015 then COUNT(stars) else 0  end  from spring group by business_id, year");


val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val springRenamed = spring1.toDF(newNames: _*)

springRenamed.registerTempTable("springRenamed")

val springFin = sqlContext.sql("select business_id , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from springRenamed group by business_id");

val springCount = springFin.toDF(newNames: _*)

springCount.registerTempTable("springCount")

springCount.show

println("summer based on count :")


val summer = sqlContext.sql("SELECT business.business_id, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=6 AND MONTH(date) <=8)  AND (YEAR(date) >=2009)");

summer.registerTempTable("summer");

val summer1 = sqlContext.sql("select business_id, case when year = 2009 then COUNT(stars) else 0 end  , case when year = 2010 then COUNT(stars) else 0 end , case when year = 2011 then COUNT(stars) else 0 end , case when year = 2012 then COUNT(stars) else 0 end , case when year = 2013 then COUNT(stars) else 0 end , case when year = 2014 then COUNT(stars) else 0 end , case when year = 2015 then COUNT(stars) else 0  end  from summer group by business_id, year");


val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val summerRenamed = summer1.toDF(newNames: _*)

summerRenamed.registerTempTable("summerRenamed")

val summerFin = sqlContext.sql("select business_id , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from summerRenamed group by business_id");

val summerCount = summerFin.toDF(newNames: _*)

summerCount.registerTempTable("summerCount")

summerCount.show

println("autumn based on count :")

val autumn = sqlContext.sql("SELECT business.business_id, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=9 AND MONTH(date) <=11)  AND (YEAR(date) >=2009)");

autumn.registerTempTable("autumn");

val autumn1 = sqlContext.sql("select business_id, case when year = 2009 then COUNT(stars) else 0 end  , case when year = 2010 then COUNT(stars) else 0 end , case when year = 2011 then COUNT(stars) else 0 end , case when year = 2012 then COUNT(stars) else 0 end , case when year = 2013 then COUNT(stars) else 0 end , case when year = 2014 then COUNT(stars) else 0 end , case when year = 2015 then COUNT(stars) else 0  end  from autumn group by business_id, year");


val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val autumnRenamed = autumn1.toDF(newNames: _*)

autumnRenamed.registerTempTable("autumnRenamed")

val autumnFin = sqlContext.sql("select business_id , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from autumnRenamed group by business_id");

val autumnCount = autumnFin.toDF(newNames: _*)

autumnCount.registerTempTable("autumnCount")

autumnCount.show 

println("winter based on count :")


val winter = sqlContext.sql("SELECT business.business_id, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=11 OR MONTH(date) <=2)  AND (YEAR(date) >=2009)");

winter.registerTempTable("winter");

val winter1 = sqlContext.sql("select business_id, case when year = 2009 then COUNT(stars) else 0 end  , case when year = 2010 then COUNT(stars) else 0 end , case when year = 2011 then COUNT(stars) else 0 end , case when year = 2012 then COUNT(stars) else 0 end , case when year = 2013 then COUNT(stars) else 0 end , case when year = 2014 then COUNT(stars) else 0 end , case when year = 2015 then COUNT(stars) else 0  end  from winter group by business_id, year");


val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val winterRenamed = winter1.toDF(newNames: _*)

winterRenamed.registerTempTable("winterRenamed")

val winterFin = sqlContext.sql("select business_id , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from winterRenamed group by business_id");

val winterCount = winterFin.toDF(newNames: _*)

winterCount.registerTempTable("winterCount")

winterCount.show


println("Different categories in different seasons :")

println("Shopping")

 val springShopping = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Shopping%'");

springShopping.registerTempTable("springShopping");

val springShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springShopping");

springShopping.registerTempTable("springShopping");

springShopping.show

 val summerShopping = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Shopping%'");

summerShopping.registerTempTable("summerShopping");

val summerShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerShopping");

summerShopping.registerTempTable("summerShopping");

summerShopping.show

 val autumnShopping = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Shopping%'");

autumnShopping.registerTempTable("autumnShopping");

val autumnShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnShopping");

autumnShopping.registerTempTable("autumnShopping");

autumnShopping.show

val winterShopping = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Shopping%'");

 winterShopping.registerTempTable("winterShopping");

val winterShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterShopping");

 winterShopping.registerTempTable("winterShopping");

winterShopping.show

Restaurants :
——————
 val springRestaurants = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Restaurants%'");

springRestaurants.registerTempTable("springRestaurants");

val springRestaurants=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springRestaurants");

springRestaurants.registerTempTable("springRestaurants");

springRestaurants.show

 val summerRestaurants = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Restaurants%'");

summerRestaurants.registerTempTable("summerRestaurants");

val summerRestaurants=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerRestaurants");

summerRestaurants.registerTempTable("summerRestaurants");

summerRestaurants.show

 val autumnRestaurants = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Restaurants%'");

autumnRestaurants.registerTempTable("autumnRestaurants");

val autumnRestaurants=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnRestaurants");

autumnRestaurants.registerTempTable("autumnRestaurants");

autumnRestaurants.show

val winterRestaurants = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Restaurants%'");

 winterRestaurants.registerTempTable("winterRestaurants");

val winterRestaurants=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterRestaurants");

 winterRestaurants.registerTempTable("winterRestaurants");

winterRestaurants.show


Food :
——————
 val springFood = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Food%'");

springFood.registerTempTable("springFood");

val springFood=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springFood");

springFood.registerTempTable("springFood");

springFood.show

 val summerFood = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Food%'");

summerFood.registerTempTable("summerFood");

val summerFood=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerFood");

summerFood.registerTempTable("summerFood");

summerFood.show

 val autumnFood = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Food%'");

autumnFood.registerTempTable("autumnFood");

val autumnFood=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnFood");

autumnFood.registerTempTable("autumnFood");

autumnFood.show

val winterFood = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Food%'");

 winterFood.registerTempTable("winterFood");

val winterFood=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterFood");

 winterFood.registerTempTable("winterFood");

winterFood.show

Medicine:
————

val springMedical = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Medical%'");

springMedical.registerTempTable("springMedical");

val springMedical=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springMedical");

springMedical.registerTempTable("springMedical");

springMedical.show

 val summerMedical = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Medical%'");

summerMedical.registerTempTable("summerMedical");

val summerMedical=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerMedical");

summerMedical.registerTempTable("summerMedical");

summerMedical.show

 val autumnMedical = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Medical%'");

autumnMedical.registerTempTable("autumnMedical");

val autumnMedical=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnMedical");

autumnMedical.registerTempTable("autumnMedical");

autumnMedical.show

val winterMedical = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Medical%'");

 winterMedical.registerTempTable("winterMedical");

val winterMedical=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterMedical");

 winterMedical.registerTempTable("winterMedical");

winterMedical.show

Beauty :
————

val springBeauty = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Beauty%'");

springBeauty.registerTempTable("springBeauty");

val springBeauty=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springBeauty");

springBeauty.registerTempTable("springBeauty");

springBeauty.show

 val summerBeauty = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Beauty%'");

summerBeauty.registerTempTable("summerBeauty");

val summerBeauty=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerBeauty");

summerBeauty.registerTempTable("summerBeauty");

summerBeauty.show

 val autumnBeauty = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Beauty%'");

autumnBeauty.registerTempTable("autumnBeauty");

val autumnBeauty=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnBeauty");

autumnBeauty.registerTempTable("autumnBeauty");

autumnBeauty.show

val winterBeauty = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Beauty%'");

 winterBeauty.registerTempTable("winterBeauty");

val winterBeauty=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterBeauty");

 winterBeauty.registerTempTable("winterBeauty");

winterBeauty.show


Grocery :
————

val springGrocery = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Grocery%'");

springGrocery.registerTempTable("springGrocery");

val springGrocery=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springGrocery");

springGrocery.registerTempTable("springGrocery");

springGrocery.show

 val summerGrocery = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Grocery%'");

summerGrocery.registerTempTable("summerGrocery");

val summerGrocery=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerGrocery");

summerGrocery.registerTempTable("summerGrocery");

summerGrocery.show

 val autumnGrocery = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Grocery%'");

autumnGrocery.registerTempTable("autumnGrocery");

val autumnGrocery=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnGrocery");

autumnGrocery.registerTempTable("autumnGrocery");

autumnGrocery.show

val winterGrocery = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Grocery%'");

 winterGrocery.registerTempTable("winterGrocery");

val winterGrocery=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterGrocery");

 winterGrocery.registerTempTable("winterGrocery");

winterGrocery.show

EventEvent :
————

val springEvent = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Event%'");

springEvent.registerTempTable("springEvent");

val springEvent=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springEvent");

springEvent.registerTempTable("springEvent");

springEvent.show

 val summerEvent = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Event%'");

summerEvent.registerTempTable("summerEvent");

val summerEvent=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerEvent");

summerEvent.registerTempTable("summerEvent");

summerEvent.show

 val autumnEvent = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Event%'");

autumnEvent.registerTempTable("autumnEvent");

val autumnEvent=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnEvent");

autumnEvent.registerTempTable("autumnEvent");

autumnEvent.show

val winterEvent = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Event%'");

 winterEvent.registerTempTable("winterEvent");

val winterEvent=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterEvent");

 winterEvent.registerTempTable("winterEvent");

winterEvent.show

School :
—————

val springSchool = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%School%'");

springSchool.registerTempTable("springSchool");

val springSchool=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springSchool");

springSchool.registerTempTable("springSchool");

springSchool.show

 val summerSchool = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%School%'");

summerSchool.registerTempTable("summerSchool");

val summerSchool=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerSchool");

summerSchool.registerTempTable("summerSchool");

summerSchool.show

 val autumnSchool = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%School%'");

autumnSchool.registerTempTable("autumnSchool");

val autumnSchool=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnSchool");

autumnSchool.registerTempTable("autumnSchool");

autumnSchool.show

val winterSchool = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%School%'");

 winterSchool.registerTempTable("winterSchool");

val winterSchool=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterSchool");

 winterSchool.registerTempTable("winterSchool");

winterSchool.show


Fashion :
—————

val springFashion = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Fashion%'");

springFashion.registerTempTable("springFashion");

val springFashion=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springFashion");

springFashion.registerTempTable("springFashion");

springFashion.show

 val summerFashion = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Fashion%'");

summerFashion.registerTempTable("summerFashion");

val summerFashion=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerFashion");

summerFashion.registerTempTable("summerFashion");

summerFashion.show

 val autumnFashion = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Fashion%'");

autumnFashion.registerTempTable("autumnFashion");

val autumnFashion=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnFashion");

autumnFashion.registerTempTable("autumnFashion");

autumnFashion.show

val winterFashion = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Fashion%'");

 winterFashion.registerTempTable("winterFashion");

val winterFashion=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterFashion");

 winterFashion.registerTempTable("winterFashion");

winterFashion.show

Home :
—————

val springHome = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Home%'");

springHome.registerTempTable("springHome");

val springHome=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springHome");

springHome.registerTempTable("springHome");

springHome.show

 val summerHome = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Home%'");

summerHome.registerTempTable("summerHome");

val summerHome=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerHome");

summerHome.registerTempTable("summerHome");

summerHome.show

 val autumnHome = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Home%'");

autumnHome.registerTempTable("autumnHome");

val autumnHome=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnHome");

autumnHome.registerTempTable("autumnHome");

autumnHome.show

val winterHome = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Home%'");

 winterHome.registerTempTable("winterHome");

val winterHome=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterHome");

 winterHome.registerTempTable("winterHome");

winterHome.show

Nightlife :
—————

val springNightlife = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Nightlife%'");

springNightlife.registerTempTable("springNightlife");

val springNightlife=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springNightlife");

springNightlife.registerTempTable("springNightlife");

springNightlife.show

 val summerNightlife = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Nightlife%'");

summerNightlife.registerTempTable("summerNightlife");

val summerNightlife=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerNightlife");

summerNightlife.registerTempTable("summerNightlife");

summerNightlife.show

 val autumnNightlife = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Nightlife%'");

autumnNightlife.registerTempTable("autumnNightlife");

val autumnNightlife=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnNightlife");

autumnNightlife.registerTempTable("autumnNightlife");

autumnNightlife.show

val winterNightlife = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Nightlife%'");

 winterNightlife.registerTempTable("winterNightlife");

val winterNightlife=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterNightlife");

 winterNightlife.registerTempTable("winterNightlife");

winterNightlife.show



—————————————————————
Based on checkin :

val checkin1 = sqlContext.sql("select business_id, checkin_info['8-1']+ checkin_info['9-1']+checkin_info['10-1']+checkin_info['11-1']+ checkin_info['8-2']+ checkin_info['9-2']+checkin_info['10-2']+checkin_info['11-2']+checkin_info['8-3']+ checkin_info['9-3']+checkin_info['10-3']+checkin_info['11-3'] +checkin_info['8-4']+ checkin_info['9-4']+checkin_info['10-4']+checkin_info['11-4'] as weekday_morning,checkin_info['12-1']+ checkin_info['13-1']+checkin_info['14-1']+checkin_info['15-1']+ checkin_info['12-2']+ checkin_info['13-2']+checkin_info['14-2']+checkin_info['15-2']+checkin_info['12-3']+ checkin_info['13-3']+checkin_info['14-3']+checkin_info['15-3'] +checkin_info['12-4']+ checkin_info['13-4']+checkin_info['14-4']+checkin_info['15-4'] as weekday_noon, checkin_info['18-1']+ checkin_info['16-1']+checkin_info['17-1']+ checkin_info['18-2']+ checkin_info['16-2']+checkin_info['17-2']+checkin_info['16-3']+ checkin_info['17-3']+checkin_info['18-3'] +checkin_info['16-4']+ checkin_info['17-4']+checkin_info['18-4'] as weekday_eve, checkin_info['19-1']+ checkin_info['20-1']+checkin_info['21-1']+checkin_info['22-1']+ checkin_info['19-2']+ checkin_info['20-2']+checkin_info['21-2']+checkin_info['22-2']+checkin_info['19-3']+ checkin_info['20-3']+checkin_info['21-3']+checkin_info['22-3'] +checkin_info['19-4']+ checkin_info['20-4']+checkin_info['21-4']+checkin_info['22-4'] as weekday_night, checkin_info['8-5']+ checkin_info['9-5']+checkin_info['10-5']+checkin_info['11-5']+ checkin_info['8-6']+ checkin_info['9-6']+checkin_info['10-6']+checkin_info['11-6']+checkin_info['8-0']+ checkin_info['9-0']+checkin_info['10-0']+checkin_info['11-0']  as weekend_morning, checkin_info['12-5']+ checkin_info['13-5']+checkin_info['14-5']+checkin_info['15-5']+ checkin_info['12-6']+ checkin_info['13-6']+checkin_info['14-6']+checkin_info['15-6']+checkin_info['12-0']+ checkin_info['13-0']+checkin_info['14-0']+checkin_info['15-0'] as weekend_noon, checkin_info['18-5']+ checkin_info['16-5']+checkin_info['17-5']+ checkin_info['18-6']+ checkin_info['16-6']+checkin_info['17-6']+checkin_info['16-0']+ checkin_info['17-0']+checkin_info['18-0'] as weekend_eve, checkin_info['19-5']+ checkin_info['20-5']+checkin_info['21-5']+checkin_info['22-5']+ checkin_info['19-6']+ checkin_info['20-6']+checkin_info['21-6']+checkin_info['22-6']+checkin_info['19-0']+ checkin_info['20-0']+checkin_info['21-0']+checkin_info['22-0']  as weekend_night from checkin")

 checkin1.registerTempTable("checkin1")

val checkinFin = sqlContext.sql("SELECT * FROM checkin1 where weekday_morning > 0 OR weekday_noon > 0 OR weekday_eve > 0 OR weekday_night > 0 OR weekend_morning > 0 OR weekend_noon > 0 OR weekend_eve > 0 OR weekend_night >0 ORDER BY weekend_night desc")

checkinFin.registerTempTable("checkinFin")



Info based on checkin :
————————————

Restaurant :

val checkinRestaurant = sqlContext.sql("select weekday_morning,weekday_noon, weekday_eve, weekday_night, weekend_morning,weekend_noon,weekend_eve,weekend_night from checkinFin,business where checkinFin.business_id == business.business_id and categories like '%Restaurants%'"); 

checkinRestaurant.registerTempTable("checkinRestaurant");


val checkinRestaurant = sqlContext.sql("select sum(weekday_morning) as weekday_morning,sum(weekday_noon) as weekday_noon, sum(weekday_eve) as weekday_eve, sum(weekday_night) as weekday_night, sum(weekend_morning) as weekend_morning,sum(weekend_noon) as weekend_noon,sum(weekend_eve) as weekend_eve,sum(weekend_night) as weekend_night from checkinRestaurant "); 

checkinRestaurant.registerTempTable("checkinRestaurant");

checkinRestaurant.show

Shopping :

val checkinShopping = sqlContext.sql("select weekday_morning,weekday_noon, weekday_eve, weekday_night, weekend_morning,weekend_noon,weekend_eve,weekend_night from checkinFin,business where checkinFin.business_id == business.business_id and categories like '%Shoppings%'"); 

checkinShopping.registerTempTable("checkinShopping");


val checkinShopping = sqlContext.sql("select sum(weekday_morning) as weekday_morning,sum(weekday_noon) as weekday_noon, sum(weekday_eve) as weekday_eve, sum(weekday_night) as weekday_night, sum(weekend_morning) as weekend_morning,sum(weekend_noon) as weekend_noon,sum(weekend_eve) as weekend_eve,sum(weekend_night) as weekend_night from checkinShopping "); 

checkinShopping.registerTempTable("checkinShopping");

checkinShopping.show

Beauty :

val checkinBeauty = sqlContext.sql("select weekday_morning,weekday_noon, weekday_eve, weekday_night, weekend_morning,weekend_noon,weekend_eve,weekend_night from checkinFin,business where checkinFin.business_id == business.business_id and categories like '%Beautys%'"); 

checkinBeauty.registerTempTable("checkinBeauty");


val checkinBeauty = sqlContext.sql("select sum(weekday_morning) as weekday_morning,sum(weekday_noon) as weekday_noon, sum(weekday_eve) as weekday_eve, sum(weekday_night) as weekday_night, sum(weekend_morning) as weekend_morning,sum(weekend_noon) as weekend_noon,sum(weekend_eve) as weekend_eve,sum(weekend_night) as weekend_night from checkinBeauty "); 

checkinBeauty.registerTempTable("checkinBeauty");

checkinBeauty.show

println("Grocery :
————")

val checkinGrocery = sqlContext.sql("select weekday_morning,weekday_noon, weekday_eve, weekday_night, weekend_morning,weekend_noon,weekend_eve,weekend_night from checkinFin,business where checkinFin.business_id == business.business_id and categories like '%Grocerys%'"); 

checkinGrocery.registerTempTable("checkinGrocery");


val checkinGrocery = sqlContext.sql("select sum(weekday_morning) as weekday_morning,sum(weekday_noon) as weekday_noon, sum(weekday_eve) as weekday_eve, sum(weekday_night) as weekday_night, sum(weekend_morning) as weekend_morning,sum(weekend_noon) as weekend_noon,sum(weekend_eve) as weekend_eve,sum(weekend_night) as weekend_night from checkinGrocery "); 

checkinGrocery.registerTempTable("checkinGrocery");

checkinGrocery.show

println("Entertainment :

———————")

val checkinEntertainment = sqlContext.sql("select weekday_morning,weekday_noon, weekday_eve, weekday_night, weekend_morning,weekend_noon,weekend_eve,weekend_night from checkinFin,business where checkinFin.business_id == business.business_id and categories like '%Entertainments%'"); 

checkinEntertainment.registerTempTable("checkinEntertainment");


val checkinEntertainment = sqlContext.sql("select sum(weekday_morning) as weekday_morning,sum(weekday_noon) as weekday_noon, sum(weekday_eve) as weekday_eve, sum(weekday_night) as weekday_night, sum(weekend_morning) as weekend_morning,sum(weekend_noon) as weekend_noon,sum(weekend_eve) as weekend_eve,sum(weekend_night) as weekend_night from checkinEntertainment "); 

checkinEntertainment.registerTempTable("checkinEntertainment");

checkinEntertainment.show


println("Checkin based on city")


val checkincity = sqlContext.sql("select checkin1.business_id , city, weekday_morning, weekday_noon, weekday_eve, weekday_night, weekend_morning, weekend_noon, weekend_eve, weekend_night from business,checkin1 where business.business_id = checkin1.business_id ");

checkincity.registerTempTable("checkincity")

val checkincityFin = sqlContext.sql("select city,sum(weekday_morning) as weekday_morning,sum(weekday_noon) as weekday_noon,sum(weekday_eve) as weekday_eve,sum(weekday_night) as weekday_night,sum(weekend_morning) as weekend_morning,sum(weekend_noon) as weekend_noon, sum(weekend_eve) as weekend_eve ,sum(weekend_night) as weekend_night from checkincity group by city order by weekend_eve desc");

checkincityFin.registerTempTable("checkincityFin");

checkincityFin.show


println("Spring city based :")


al spring = sqlContext.sql("SELECT business.business_id,city, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=3 AND MONTH(date) <=5)  AND (YEAR(date) >=2009)");

spring.registerTempTable("spring");

val spring1 = sqlContext.sql("select business_id,city, case when year = 2009 then COUNT(stars) else 0 end  , case when year = 2010 then COUNT(stars) else 0 end , case when year = 2011 then COUNT(stars) else 0 end , case when year = 2012 then COUNT(stars) else 0 end , case when year = 2013 then COUNT(stars) else 0 end , case when year = 2014 then COUNT(stars) else 0 end , case when year = 2015 then COUNT(stars) else 0  end  from spring group by city, year,business_id");

val newNames = Seq("business_id","city", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val springRenamed = spring1.toDF(newNames: _*)

springRenamed.registerTempTable("springRenamed")

val springFin = sqlContext.sql("select business_id,city , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from springRenamed group by business_id,city");

val springCity = springFin.toDF(newNames: _*)

springCity.registerTempTable("springCity")

springCity.show


println("—————————————————————————
Summer Based on city")


val summer = sqlContext.sql("SELECT business.business_id,city, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=6 AND MONTH(date) <=8)  AND (YEAR(date) >=2009)");

summer.registerTempTable("summer");

val summer1 = sqlContext.sql("select business_id,city, case when year = 2009 then COUNT(stars) else 0 end  , case when year = 2010 then COUNT(stars) else 0 end , case when year = 2011 then COUNT(stars) else 0 end , case when year = 2012 then COUNT(stars) else 0 end , case when year = 2013 then COUNT(stars) else 0 end , case when year = 2014 then COUNT(stars) else 0 end , case when year = 2015 then COUNT(stars) else 0  end  from summer group by city,business_id, year");


val newNames = Seq("business_id","city", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val summerRenamed = summer1.toDF(newNames: _*)

summerRenamed.registerTempTable("summerRenamed")

val summerFin = sqlContext.sql("select business_id,city , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from summerRenamed group by business_id,city")

val summerCity = summerFin.toDF(newNames: _*)

summerCity.registerTempTable("summerCity")

summerCity.show


summerCity.show
println("——————————————————
Autumn Based on City")



val autumn = sqlContext.sql("SELECT business.business_id,city, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=9 AND MONTH(date) <=11)  AND (YEAR(date) >=2009)");

autumn.registerTempTable("autumn");

val autumn1 = sqlContext.sql("select business_id,city, case when year = 2009 then COUNT(stars) else 0 end  , case when year = 2010 then COUNT(stars) else 0 end , case when year = 2011 then COUNT(stars) else 0 end , case when year = 2012 then COUNT(stars) else 0 end , case when year = 2013 then COUNT(stars) else 0 end , case when year = 2014 then COUNT(stars) else 0 end , case when year = 2015 then COUNT(stars) else 0  end  from autumn group by city,business_id, year");


val newNames = Seq("business_id","city", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val autumnRenamed = autumn1.toDF(newNames: _*)

autumnRenamed.registerTempTable("autumnRenamed")

val autumnFin = sqlContext.sql("select business_id,city , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from autumnRenamed group by business_id,city")

val autumnCity = autumnFin.toDF(newNames: _*)

autumnCity.registerTempTable("autumnCity")

autumnCity.show


println("Winter Based on city:
———————")

val winter = sqlContext.sql("SELECT business.business_id,city, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=11 OR MONTH(date) <=2)  AND (YEAR(date) >=2009)");

winter.registerTempTable("winter");

val winter1 = sqlContext.sql("select business_id,city, case when year = 2009 then COUNT(stars) else 0 end  , case when year = 2010 then COUNT(stars) else 0 end , case when year = 2011 then COUNT(stars) else 0 end , case when year = 2012 then COUNT(stars) else 0 end , case when year = 2013 then COUNT(stars) else 0 end , case when year = 2014 then COUNT(stars) else 0 end , case when year = 2015 then COUNT(stars) else 0  end  from winter group by city,business_id, year");


val newNames = Seq("business_id","city", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val winterRenamed = winter1.toDF(newNames: _*)

winterRenamed.registerTempTable("winterRenamed")

val winterFin = sqlContext.sql("select business_id,city , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from winterRenamed group by business_id,city")

val winterCity = winterFin.toDF(newNames: _*)

winterCity.registerTempTable("winterCity")


—————————————————————
Analysis based on city and business type :


println("Shopping in Vegas :
——————")
val springShopping = sqlContext.sql("select springCity.business_id, year1,year2,year3,year4,year5,year6,year7 from springCity,business where springCity.business_id=business.business_id and springCity.city like 'Las Vegas' and categories like '%Shopping%'");

springShopping.registerTempTable("springShopping");

val springShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springShopping");

springShopping.registerTempTable("springShopping");

springShopping.show

 val summerShopping = sqlContext.sql("select summerCity.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCity,business where summerCity.business_id=business.business_id and summerCity.city like 'Las Vegas' and categories like '%Shopping%'");

summerShopping.registerTempTable("summerShopping");

val summerShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerShopping");

summerShopping.registerTempTable("summerShopping");

summerShopping.show

 val autumnShopping = sqlContext.sql("select autumnCity.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCity,business where autumnCity.business_id=business.business_id and autumnCity.city like 'Las Vegas' and categories like '%Shopping%'");

autumnShopping.registerTempTable("autumnShopping");

val autumnShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnShopping");

autumnShopping.registerTempTable("autumnShopping");

autumnShopping.show

val winterShopping = sqlContext.sql("select winterCity.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCity,business where winterCity.business_id=business.business_id and winterCity.city like 'Las Vegas' and categories like '%Shopping%'");

 winterShopping.registerTempTable("winterShopping");

val winterShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterShopping");

 winterShopping.registerTempTable("winterShopping");

winterShopping.show


println("Shopping in Montreal :
——————————")

val springShopping = sqlContext.sql("select springCity.business_id, year1,year2,year3,year4,year5,year6,year7 from springCity,business where springCity.business_id=business.business_id and springCity.city like 'Montreal' and categories like '%Shopping%'");

springShopping.registerTempTable("springShopping");

val springShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springShopping");

springShopping.registerTempTable("springShopping");

springShopping.show

 val summerShopping = sqlContext.sql("select summerCity.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCity,business where summerCity.business_id=business.business_id and summerCity.city like 'Montreal' and categories like '%Shopping%'");

summerShopping.registerTempTable("summerShopping");

val summerShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerShopping");

summerShopping.registerTempTable("summerShopping");

summerShopping.show

 val autumnShopping = sqlContext.sql("select autumnCity.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCity,business where autumnCity.business_id=business.business_id and autumnCity.city like 'Montreal' and categories like '%Shopping%'");

autumnShopping.registerTempTable("autumnShopping");

val autumnShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnShopping");

autumnShopping.registerTempTable("autumnShopping");

autumnShopping.show

val winterShopping = sqlContext.sql("select winterCity.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCity,business where winterCity.business_id=business.business_id and winterCity.city like 'Montreal' and categories like '%Shopping%'");

 winterShopping.registerTempTable("winterShopping");

val winterShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterShopping");

 winterShopping.registerTempTable("winterShopping");

winterShopping.show


println("Restaurants in Las vegas
—————————————")

val springRestaurant = sqlContext.sql("select springCity.business_id, year1,year2,year3,year4,year5,year6,year7 from springCity,business where springCity.business_id=business.business_id and springCity.city like 'Las Vegas' and categories like '%Restaurant%'");

springRestaurant.registerTempTable("springRestaurant");

val springRestaurant=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springRestaurant");

springRestaurant.registerTempTable("springRestaurant");

springRestaurant.show

 val summerRestaurant = sqlContext.sql("select summerCity.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCity,business where summerCity.business_id=business.business_id and summerCity.city like 'Las Vegas' and categories like '%Restaurant%'");

summerRestaurant.registerTempTable("summerRestaurant");

val summerRestaurant=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerRestaurant");

summerRestaurant.registerTempTable("summerRestaurant");

summerRestaurant.show

 val autumnRestaurant = sqlContext.sql("select autumnCity.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCity,business where autumnCity.business_id=business.business_id and autumnCity.city like 'Las Vegas' and categories like '%Restaurant%'");

autumnRestaurant.registerTempTable("autumnRestaurant");

val autumnRestaurant=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnRestaurant");

autumnRestaurant.registerTempTable("autumnRestaurant");

autumnRestaurant.show

val winterRestaurant = sqlContext.sql("select winterCity.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCity,business where winterCity.business_id=business.business_id and winterCity.city like 'Las Vegas' and categories like '%Restaurant%'");

 winterRestaurant.registerTempTable("winterRestaurant");

val winterRestaurant=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterRestaurant");

 winterRestaurant.registerTempTable("winterRestaurant");

winterRestaurant.show

println("Restaurant in Montreal :")


val springRestaurant = sqlContext.sql("select springCity.business_id, year1,year2,year3,year4,year5,year6,year7 from springCity,business where springCity.business_id=business.business_id and springCity.city like 'Montreal' and categories like '%Restaurant%'");

springRestaurant.registerTempTable("springRestaurant");

val springRestaurant=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springRestaurant");

springRestaurant.registerTempTable("springRestaurant");

springRestaurant.show

 val summerRestaurant = sqlContext.sql("select summerCity.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCity,business where summerCity.business_id=business.business_id and summerCity.city like 'Montreal' and categories like '%Restaurant%'");

summerRestaurant.registerTempTable("summerRestaurant");

val summerRestaurant=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerRestaurant");

summerRestaurant.registerTempTable("summerRestaurant");

summerRestaurant.show

 val autumnRestaurant = sqlContext.sql("select autumnCity.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCity,business where autumnCity.business_id=business.business_id and autumnCity.city like 'Montreal' and categories like '%Restaurant%'");

autumnRestaurant.registerTempTable("autumnRestaurant");

val autumnRestaurant=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnRestaurant");

autumnRestaurant.registerTempTable("autumnRestaurant");

autumnRestaurant.show

val winterRestaurant = sqlContext.sql("select winterCity.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCity,business where winterCity.business_id=business.business_id and winterCity.city like 'Montreal' and categories like '%Restaurant%'");

 winterRestaurant.registerTempTable("winterRestaurant");

val winterRestaurant=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterRestaurant");

 winterRestaurant.registerTempTable("winterRestaurant");

winterRestaurant.show

println("Execution complete")

println("Please loook at the R code")

println("Sparking shutting down")




println("Get input for time series analysis :")



println("SPRING :")


val spring = sqlContext.sql("SELECT business.business_id, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=3 AND MONTH(date) <=5)  AND (YEAR(date) >=2009)");

spring.registerTempTable("spring");

val spring1 = sqlContext.sql("select business_id, case when year = 2009 then AVG(stars) else 0 end  , case when year = 2010 then AVG(stars) else 0 end , case when year = 2011 then AVG(stars) else 0 end , case when year = 2012 then AVG(stars) else 0 end , case when year = 2013 then AVG(stars) else 0 end , case when year = 2014 then AVG(stars) else 0 end , case when year = 2015 then AVG(stars) else 0  end  from spring group by business_id, year");


val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val springRenamed = spring1.toDF(newNames: _*)

springRenamed.registerTempTable("springRenamed")

val springFin = sqlContext.sql("select business_id , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from springRenamed group by business_id");

val springRenamed = springFin.toDF(newNames: _*)

springRenamed.registerTempTable("springRenamed")

val spring2 = sqlContext.sql("select business_id,count(stars) as count from spring group by business_id");

spring2.registerTempTable("spring2")

val springFin = sqlContext.sql("select springRenamed.business_id,year1,year2,year3,year4,year5,year6,year7,count from springRenamed, spring2 where spring2.business_id == springRenamed.business_id");

springFin.registerTempTable("springFin")

val springRes = sqlContext.sql("select business_id, case when year1 = 0 then 2.5 else sum(year1) end  , case when year2 = 0 then 2.5 else sum(year2) end , case when year3 = 0 then 2.5 else sum(year3) end , case when year4 = 0 then 2.5 else sum(year4) end , case when year5 = 0 then 2.5 else sum(year5) end , case when year6 = 0 then 2.5 else sum(year6) end , case when year7 = 0 then 2.5 else sum(year7) end,sum(count)  from springFin group by business_id,year1,year2,year3,year4,year5,year6,year7,count");

val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7","count")

val springRenamed = springRes.toDF(newNames: _*)

springRenamed.registerTempTable("springRenamed")


val springAvg = sqlContext.sql("select *, (year1+year2+year3+year4+year5+year6+year7)/7 as average from springRenamed ");

springAvg.registerTempTable("springAvg")

springAvg.show



println("SUMMER")

val summer = sqlContext.sql("SELECT business.business_id, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=6 AND MONTH(date) <=8)  AND (YEAR(date) >=2009)");

summer.registerTempTable("summer");

val summer1 = sqlContext.sql("select business_id, case when year = 2009 then AVG(stars) else 0 end  , case when year = 2010 then AVG(stars) else 0 end , case when year = 2011 then AVG(stars) else 0 end , case when year = 2012 then AVG(stars) else 0 end , case when year = 2013 then AVG(stars) else 0 end , case when year = 2014 then AVG(stars) else 0 end , case when year = 2015 then AVG(stars) else 0  end  from summer group by business_id, year");


val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val summerRenamed = summer1.toDF(newNames: _*)

summerRenamed.registerTempTable("summerRenamed")

val summerFin = sqlContext.sql("select business_id , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from summerRenamed group by business_id");

val summerRenamed = summerFin.toDF(newNames: _*)

summerRenamed.registerTempTable("summerRenamed")

val summer2 = sqlContext.sql("select business_id,count(stars) as count from summer group by business_id");

summer2.registerTempTable("summer2")

val summerFin = sqlContext.sql("select summerRenamed.business_id,year1,year2,year3,year4,year5,year6,year7,count from summerRenamed, summer2 where summer2.business_id == summerRenamed.business_id");

summerFin.registerTempTable("summerFin")

val summerRes = sqlContext.sql("select business_id, case when year1 = 0 then 2.5 else sum(year1) end  , case when year2 = 0 then 2.5 else sum(year2) end , case when year3 = 0 then 2.5 else sum(year3) end , case when year4 = 0 then 2.5 else sum(year4) end , case when year5 = 0 then 2.5 else sum(year5) end , case when year6 = 0 then 2.5 else sum(year6) end , case when year7 = 0 then 2.5 else sum(year7) end,sum(count)  from summerFin group by business_id,year1,year2,year3,year4,year5,year6,year7,count");

val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7","count")

val summerRenamed = summerRes.toDF(newNames: _*)

summerRenamed.registerTempTable("summerRenamed")


val summerAvg = sqlContext.sql("select *, (year1+year2+year3+year4+year5+year6+year7)/7 as average from summerRenamed ");

summerFin.registerTempTable("summerAvg")

summerAvg.show




println("Autumn") 


val autumn = sqlContext.sql("SELECT business.business_id, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=9 AND MONTH(date) <=11)  AND (YEAR(date) >=2009)");

autumn.registerTempTable("autumn");

val autumn1 = sqlContext.sql("select business_id, case when year = 2009 then AVG(stars) else 0 end  , case when year = 2010 then AVG(stars) else 0 end , case when year = 2011 then AVG(stars) else 0 end , case when year = 2012 then AVG(stars) else 0 end , case when year = 2013 then AVG(stars) else 0 end , case when year = 2014 then AVG(stars) else 0 end , case when year = 2015 then AVG(stars) else 0  end  from autumn group by business_id, year");


val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val autumnRenamed = autumn1.toDF(newNames: _*)

autumnRenamed.registerTempTable("autumnRenamed")

val autumnFin = sqlContext.sql("select business_id , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from autumnRenamed group by business_id");

val autumnRenamed = autumnFin.toDF(newNames: _*)

autumnRenamed.registerTempTable("autumnRenamed")

val autumn2 = sqlContext.sql("select business_id,count(stars) as count from autumn group by business_id");

autumn2.registerTempTable("autumn2")

val autumnFin = sqlContext.sql("select autumnRenamed.business_id,year1,year2,year3,year4,year5,year6,year7,count from autumnRenamed, autumn2 where autumn2.business_id == autumnRenamed.business_id");

autumnFin.registerTempTable("autumnFin")

val autumnRes = sqlContext.sql("select business_id, case when year1 = 0 then 2.5 else sum(year1) end  , case when year2 = 0 then 2.5 else sum(year2) end , case when year3 = 0 then 2.5 else sum(year3) end , case when year4 = 0 then 2.5 else sum(year4) end , case when year5 = 0 then 2.5 else sum(year5) end , case when year6 = 0 then 2.5 else sum(year6) end , case when year7 = 0 then 2.5 else sum(year7) end,sum(count)  from autumnFin group by business_id,year1,year2,year3,year4,year5,year6,year7,count");

val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7","count")

val autumnRenamed = autumnRes.toDF(newNames: _*)


autumnRenamed.registerTempTable("autumnRenamed")


val autumnAvg = sqlContext.sql("select *, (year1+year2+year3+year4+year5+year6+year7)/7 as average from autumnRenamed ");

autumnAvg.registerTempTable("autumnAvg")

autumnAvg.show




println("Winter: ")


val winter = sqlContext.sql("SELECT business.business_id, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=11 OR MONTH(date) <=2)  AND (YEAR(date) >=2009)");

winter.registerTempTable("winter");

val winter1 = sqlContext.sql("select business_id, case when year = 2009 then AVG(stars) else 0 end  , case when year = 2010 then AVG(stars) else 0 end , case when year = 2011 then AVG(stars) else 0 end , case when year = 2012 then AVG(stars) else 0 end , case when year = 2013 then AVG(stars) else 0 end , case when year = 2014 then AVG(stars) else 0 end , case when year = 2015 then AVG(stars) else 0  end  from winter group by business_id, year");


val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val winterRenamed = winter1.toDF(newNames: _*)

winterRenamed.registerTempTable("winterRenamed")

val winterFin = sqlContext.sql("select business_id , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from winterRenamed group by business_id");

val winterRenamed = winterFin.toDF(newNames: _*)

winterRenamed.registerTempTable("winterRenamed")

val winter2 = sqlContext.sql("select business_id,count(stars) as count from winter group by business_id");

winter2.registerTempTable("winter2")

val winterFin = sqlContext.sql("select winterRenamed.business_id,year1,year2,year3,year4,year5,year6,year7,count from winterRenamed, winter2 where winter2.business_id == winterRenamed.business_id");

winterFin.registerTempTable("winterFin")

val winterRes = sqlContext.sql("select business_id, case when year1 = 0 then 2.5 else sum(year1) end  , case when year2 = 0 then 2.5 else sum(year2) end , case when year3 = 0 then 2.5 else sum(year3) end , case when year4 = 0 then 2.5 else sum(year4) end , case when year5 = 0 then 2.5 else sum(year5) end , case when year6 = 0 then 2.5 else sum(year6) end , case when year7 = 0 then 2.5 else sum(year7) end,sum(count)  from winterFin group by business_id,year1,year2,year3,year4,year5,year6,year7,count");

val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7","count")

val winterRenamed = winterRes.toDF(newNames: _*)


winterRenamed.registerTempTable("winterRenamed")


val winterAvg = sqlContext.sql("select *, (year1+year2+year3+year4+year5+year6+year7)/7 as average from winterRenamed ");

winterAvg.registerTempTable("winterAvg")



println("spring based on count :")


val spring = sqlContext.sql("SELECT business.business_id, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=3 AND MONTH(date) <=5)  AND (YEAR(date) >=2009)");

spring.registerTempTable("spring");

val spring1 = sqlContext.sql("select business_id, case when year = 2009 then COUNT(stars) else 0 end  , case when year = 2010 then COUNT(stars) else 0 end , case when year = 2011 then COUNT(stars) else 0 end , case when year = 2012 then COUNT(stars) else 0 end , case when year = 2013 then COUNT(stars) else 0 end , case when year = 2014 then COUNT(stars) else 0 end , case when year = 2015 then COUNT(stars) else 0  end  from spring group by business_id, year");


val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val springRenamed = spring1.toDF(newNames: _*)

springRenamed.registerTempTable("springRenamed")

val springFin = sqlContext.sql("select business_id , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from springRenamed group by business_id");

val springCount = springFin.toDF(newNames: _*)

springCount.registerTempTable("springCount")

springCount.show

println("summer based on count :")


val summer = sqlContext.sql("SELECT business.business_id, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=6 AND MONTH(date) <=8)  AND (YEAR(date) >=2009)");

summer.registerTempTable("summer");

val summer1 = sqlContext.sql("select business_id, case when year = 2009 then COUNT(stars) else 0 end  , case when year = 2010 then COUNT(stars) else 0 end , case when year = 2011 then COUNT(stars) else 0 end , case when year = 2012 then COUNT(stars) else 0 end , case when year = 2013 then COUNT(stars) else 0 end , case when year = 2014 then COUNT(stars) else 0 end , case when year = 2015 then COUNT(stars) else 0  end  from summer group by business_id, year");


val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val summerRenamed = summer1.toDF(newNames: _*)

summerRenamed.registerTempTable("summerRenamed")

val summerFin = sqlContext.sql("select business_id , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from summerRenamed group by business_id");

val summerCount = summerFin.toDF(newNames: _*)

summerCount.registerTempTable("summerCount")

summerCount.show

println("autumn based on count :")

val autumn = sqlContext.sql("SELECT business.business_id, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=9 AND MONTH(date) <=11)  AND (YEAR(date) >=2009)");

autumn.registerTempTable("autumn");

val autumn1 = sqlContext.sql("select business_id, case when year = 2009 then COUNT(stars) else 0 end  , case when year = 2010 then COUNT(stars) else 0 end , case when year = 2011 then COUNT(stars) else 0 end , case when year = 2012 then COUNT(stars) else 0 end , case when year = 2013 then COUNT(stars) else 0 end , case when year = 2014 then COUNT(stars) else 0 end , case when year = 2015 then COUNT(stars) else 0  end  from autumn group by business_id, year");


val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val autumnRenamed = autumn1.toDF(newNames: _*)

autumnRenamed.registerTempTable("autumnRenamed")

val autumnFin = sqlContext.sql("select business_id , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from autumnRenamed group by business_id");

val autumnCount = autumnFin.toDF(newNames: _*)

autumnCount.registerTempTable("autumnCount")

autumnCount.show 

println("winter based on count :")


val winter = sqlContext.sql("SELECT business.business_id, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=11 OR MONTH(date) <=2)  AND (YEAR(date) >=2009)");

winter.registerTempTable("winter");

val winter1 = sqlContext.sql("select business_id, case when year = 2009 then COUNT(stars) else 0 end  , case when year = 2010 then COUNT(stars) else 0 end , case when year = 2011 then COUNT(stars) else 0 end , case when year = 2012 then COUNT(stars) else 0 end , case when year = 2013 then COUNT(stars) else 0 end , case when year = 2014 then COUNT(stars) else 0 end , case when year = 2015 then COUNT(stars) else 0  end  from winter group by business_id, year");


val newNames = Seq("business_id", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val winterRenamed = winter1.toDF(newNames: _*)

winterRenamed.registerTempTable("winterRenamed")

val winterFin = sqlContext.sql("select business_id , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from winterRenamed group by business_id");

val winterCount = winterFin.toDF(newNames: _*)

winterCount.registerTempTable("winterCount")

winterCount.show


println("Different categories in different seasons :")

println("Shopping")

 val springShopping = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Shopping%'");

springShopping.registerTempTable("springShopping");

val springShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springShopping");

springShopping.registerTempTable("springShopping");

springShopping.show

 val summerShopping = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Shopping%'");

summerShopping.registerTempTable("summerShopping");

val summerShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerShopping");

summerShopping.registerTempTable("summerShopping");

summerShopping.show

 val autumnShopping = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Shopping%'");

autumnShopping.registerTempTable("autumnShopping");

val autumnShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnShopping");

autumnShopping.registerTempTable("autumnShopping");

autumnShopping.show

val winterShopping = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Shopping%'");

 winterShopping.registerTempTable("winterShopping");

val winterShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterShopping");

 winterShopping.registerTempTable("winterShopping");

winterShopping.show

Restaurants :
——————
 val springRestaurants = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Restaurants%'");

springRestaurants.registerTempTable("springRestaurants");

val springRestaurants=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springRestaurants");

springRestaurants.registerTempTable("springRestaurants");

springRestaurants.show

 val summerRestaurants = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Restaurants%'");

summerRestaurants.registerTempTable("summerRestaurants");

val summerRestaurants=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerRestaurants");

summerRestaurants.registerTempTable("summerRestaurants");

summerRestaurants.show

 val autumnRestaurants = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Restaurants%'");

autumnRestaurants.registerTempTable("autumnRestaurants");

val autumnRestaurants=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnRestaurants");

autumnRestaurants.registerTempTable("autumnRestaurants");

autumnRestaurants.show

val winterRestaurants = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Restaurants%'");

 winterRestaurants.registerTempTable("winterRestaurants");

val winterRestaurants=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterRestaurants");

 winterRestaurants.registerTempTable("winterRestaurants");

winterRestaurants.show


Food :
——————
 val springFood = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Food%'");

springFood.registerTempTable("springFood");

val springFood=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springFood");

springFood.registerTempTable("springFood");

springFood.show

 val summerFood = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Food%'");

summerFood.registerTempTable("summerFood");

val summerFood=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerFood");

summerFood.registerTempTable("summerFood");

summerFood.show

 val autumnFood = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Food%'");

autumnFood.registerTempTable("autumnFood");

val autumnFood=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnFood");

autumnFood.registerTempTable("autumnFood");

autumnFood.show

val winterFood = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Food%'");

 winterFood.registerTempTable("winterFood");

val winterFood=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterFood");

 winterFood.registerTempTable("winterFood");

winterFood.show

Medicine:
————

val springMedical = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Medical%'");

springMedical.registerTempTable("springMedical");

val springMedical=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springMedical");

springMedical.registerTempTable("springMedical");

springMedical.show

 val summerMedical = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Medical%'");

summerMedical.registerTempTable("summerMedical");

val summerMedical=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerMedical");

summerMedical.registerTempTable("summerMedical");

summerMedical.show

 val autumnMedical = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Medical%'");

autumnMedical.registerTempTable("autumnMedical");

val autumnMedical=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnMedical");

autumnMedical.registerTempTable("autumnMedical");

autumnMedical.show

val winterMedical = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Medical%'");

 winterMedical.registerTempTable("winterMedical");

val winterMedical=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterMedical");

 winterMedical.registerTempTable("winterMedical");

winterMedical.show

Beauty :
————

val springBeauty = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Beauty%'");

springBeauty.registerTempTable("springBeauty");

val springBeauty=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springBeauty");

springBeauty.registerTempTable("springBeauty");

springBeauty.show

 val summerBeauty = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Beauty%'");

summerBeauty.registerTempTable("summerBeauty");

val summerBeauty=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerBeauty");

summerBeauty.registerTempTable("summerBeauty");

summerBeauty.show

 val autumnBeauty = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Beauty%'");

autumnBeauty.registerTempTable("autumnBeauty");

val autumnBeauty=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnBeauty");

autumnBeauty.registerTempTable("autumnBeauty");

autumnBeauty.show

val winterBeauty = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Beauty%'");

 winterBeauty.registerTempTable("winterBeauty");

val winterBeauty=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterBeauty");

 winterBeauty.registerTempTable("winterBeauty");

winterBeauty.show


Grocery :
————

val springGrocery = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Grocery%'");

springGrocery.registerTempTable("springGrocery");

val springGrocery=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springGrocery");

springGrocery.registerTempTable("springGrocery");

springGrocery.show

 val summerGrocery = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Grocery%'");

summerGrocery.registerTempTable("summerGrocery");

val summerGrocery=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerGrocery");

summerGrocery.registerTempTable("summerGrocery");

summerGrocery.show

 val autumnGrocery = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Grocery%'");

autumnGrocery.registerTempTable("autumnGrocery");

val autumnGrocery=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnGrocery");

autumnGrocery.registerTempTable("autumnGrocery");

autumnGrocery.show

val winterGrocery = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Grocery%'");

 winterGrocery.registerTempTable("winterGrocery");

val winterGrocery=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterGrocery");

 winterGrocery.registerTempTable("winterGrocery");

winterGrocery.show

EventEvent :
————

val springEvent = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Event%'");

springEvent.registerTempTable("springEvent");

val springEvent=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springEvent");

springEvent.registerTempTable("springEvent");

springEvent.show

 val summerEvent = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Event%'");

summerEvent.registerTempTable("summerEvent");

val summerEvent=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerEvent");

summerEvent.registerTempTable("summerEvent");

summerEvent.show

 val autumnEvent = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Event%'");

autumnEvent.registerTempTable("autumnEvent");

val autumnEvent=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnEvent");

autumnEvent.registerTempTable("autumnEvent");

autumnEvent.show

val winterEvent = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Event%'");

 winterEvent.registerTempTable("winterEvent");

val winterEvent=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterEvent");

 winterEvent.registerTempTable("winterEvent");

winterEvent.show

School :
—————

val springSchool = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%School%'");

springSchool.registerTempTable("springSchool");

val springSchool=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springSchool");

springSchool.registerTempTable("springSchool");

springSchool.show

 val summerSchool = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%School%'");

summerSchool.registerTempTable("summerSchool");

val summerSchool=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerSchool");

summerSchool.registerTempTable("summerSchool");

summerSchool.show

 val autumnSchool = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%School%'");

autumnSchool.registerTempTable("autumnSchool");

val autumnSchool=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnSchool");

autumnSchool.registerTempTable("autumnSchool");

autumnSchool.show

val winterSchool = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%School%'");

 winterSchool.registerTempTable("winterSchool");

val winterSchool=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterSchool");

 winterSchool.registerTempTable("winterSchool");

winterSchool.show


Fashion :
—————

val springFashion = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Fashion%'");

springFashion.registerTempTable("springFashion");

val springFashion=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springFashion");

springFashion.registerTempTable("springFashion");

springFashion.show

 val summerFashion = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Fashion%'");

summerFashion.registerTempTable("summerFashion");

val summerFashion=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerFashion");

summerFashion.registerTempTable("summerFashion");

summerFashion.show

 val autumnFashion = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Fashion%'");

autumnFashion.registerTempTable("autumnFashion");

val autumnFashion=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnFashion");

autumnFashion.registerTempTable("autumnFashion");

autumnFashion.show

val winterFashion = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Fashion%'");

 winterFashion.registerTempTable("winterFashion");

val winterFashion=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterFashion");

 winterFashion.registerTempTable("winterFashion");

winterFashion.show

Home :
—————

val springHome = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Home%'");

springHome.registerTempTable("springHome");

val springHome=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springHome");

springHome.registerTempTable("springHome");

springHome.show

 val summerHome = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Home%'");

summerHome.registerTempTable("summerHome");

val summerHome=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerHome");

summerHome.registerTempTable("summerHome");

summerHome.show

 val autumnHome = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Home%'");

autumnHome.registerTempTable("autumnHome");

val autumnHome=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnHome");

autumnHome.registerTempTable("autumnHome");

autumnHome.show

val winterHome = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Home%'");

 winterHome.registerTempTable("winterHome");

val winterHome=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterHome");

 winterHome.registerTempTable("winterHome");

winterHome.show

Nightlife :
—————

val springNightlife = sqlContext.sql("select springCount.business_id, year1,year2,year3,year4,year5,year6,year7 from springCount,business where springCount.business_id=business.business_id and categories like '%Nightlife%'");

springNightlife.registerTempTable("springNightlife");

val springNightlife=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springNightlife");

springNightlife.registerTempTable("springNightlife");

springNightlife.show

 val summerNightlife = sqlContext.sql("select summerCount.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCount,business where summerCount.business_id=business.business_id and categories like '%Nightlife%'");

summerNightlife.registerTempTable("summerNightlife");

val summerNightlife=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerNightlife");

summerNightlife.registerTempTable("summerNightlife");

summerNightlife.show

 val autumnNightlife = sqlContext.sql("select autumnCount.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCount,business where autumnCount.business_id=business.business_id and categories like '%Nightlife%'");

autumnNightlife.registerTempTable("autumnNightlife");

val autumnNightlife=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnNightlife");

autumnNightlife.registerTempTable("autumnNightlife");

autumnNightlife.show

val winterNightlife = sqlContext.sql("select winterCount.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCount,business where winterCount.business_id=business.business_id and categories like '%Nightlife%'");

 winterNightlife.registerTempTable("winterNightlife");

val winterNightlife=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterNightlife");

 winterNightlife.registerTempTable("winterNightlife");

winterNightlife.show




println("Based on checkin :")

val checkin1 = sqlContext.sql("select business_id, checkin_info['8-1']+ checkin_info['9-1']+checkin_info['10-1']+checkin_info['11-1']+ checkin_info['8-2']+ checkin_info['9-2']+checkin_info['10-2']+checkin_info['11-2']+checkin_info['8-3']+ checkin_info['9-3']+checkin_info['10-3']+checkin_info['11-3'] +checkin_info['8-4']+ checkin_info['9-4']+checkin_info['10-4']+checkin_info['11-4'] as weekday_morning,checkin_info['12-1']+ checkin_info['13-1']+checkin_info['14-1']+checkin_info['15-1']+ checkin_info['12-2']+ checkin_info['13-2']+checkin_info['14-2']+checkin_info['15-2']+checkin_info['12-3']+ checkin_info['13-3']+checkin_info['14-3']+checkin_info['15-3'] +checkin_info['12-4']+ checkin_info['13-4']+checkin_info['14-4']+checkin_info['15-4'] as weekday_noon, checkin_info['18-1']+ checkin_info['16-1']+checkin_info['17-1']+ checkin_info['18-2']+ checkin_info['16-2']+checkin_info['17-2']+checkin_info['16-3']+ checkin_info['17-3']+checkin_info['18-3'] +checkin_info['16-4']+ checkin_info['17-4']+checkin_info['18-4'] as weekday_eve, checkin_info['19-1']+ checkin_info['20-1']+checkin_info['21-1']+checkin_info['22-1']+ checkin_info['19-2']+ checkin_info['20-2']+checkin_info['21-2']+checkin_info['22-2']+checkin_info['19-3']+ checkin_info['20-3']+checkin_info['21-3']+checkin_info['22-3'] +checkin_info['19-4']+ checkin_info['20-4']+checkin_info['21-4']+checkin_info['22-4'] as weekday_night, checkin_info['8-5']+ checkin_info['9-5']+checkin_info['10-5']+checkin_info['11-5']+ checkin_info['8-6']+ checkin_info['9-6']+checkin_info['10-6']+checkin_info['11-6']+checkin_info['8-0']+ checkin_info['9-0']+checkin_info['10-0']+checkin_info['11-0']  as weekend_morning, checkin_info['12-5']+ checkin_info['13-5']+checkin_info['14-5']+checkin_info['15-5']+ checkin_info['12-6']+ checkin_info['13-6']+checkin_info['14-6']+checkin_info['15-6']+checkin_info['12-0']+ checkin_info['13-0']+checkin_info['14-0']+checkin_info['15-0'] as weekend_noon, checkin_info['18-5']+ checkin_info['16-5']+checkin_info['17-5']+ checkin_info['18-6']+ checkin_info['16-6']+checkin_info['17-6']+checkin_info['16-0']+ checkin_info['17-0']+checkin_info['18-0'] as weekend_eve, checkin_info['19-5']+ checkin_info['20-5']+checkin_info['21-5']+checkin_info['22-5']+ checkin_info['19-6']+ checkin_info['20-6']+checkin_info['21-6']+checkin_info['22-6']+checkin_info['19-0']+ checkin_info['20-0']+checkin_info['21-0']+checkin_info['22-0']  as weekend_night from checkin")

 checkin1.registerTempTable("checkin1")

val checkinFin = sqlContext.sql("SELECT * FROM checkin1 where weekday_morning > 0 OR weekday_noon > 0 OR weekday_eve > 0 OR weekday_night > 0 OR weekend_morning > 0 OR weekend_noon > 0 OR weekend_eve > 0 OR weekend_night >0 ORDER BY weekend_night desc")

checkinFin.registerTempTable("checkinFin")



println("Info based on checkin : ")


println("Restaurant :")

val checkinRestaurant = sqlContext.sql("select weekday_morning,weekday_noon, weekday_eve, weekday_night, weekend_morning,weekend_noon,weekend_eve,weekend_night from checkinFin,business where checkinFin.business_id == business.business_id and categories like '%Restaurants%'"); 

checkinRestaurant.registerTempTable("checkinRestaurant");


val checkinRestaurant = sqlContext.sql("select sum(weekday_morning) as weekday_morning,sum(weekday_noon) as weekday_noon, sum(weekday_eve) as weekday_eve, sum(weekday_night) as weekday_night, sum(weekend_morning) as weekend_morning,sum(weekend_noon) as weekend_noon,sum(weekend_eve) as weekend_eve,sum(weekend_night) as weekend_night from checkinRestaurant "); 

checkinRestaurant.registerTempTable("checkinRestaurant");

checkinRestaurant.show

println("Shopping : ")

val checkinShopping = sqlContext.sql("select weekday_morning,weekday_noon, weekday_eve, weekday_night, weekend_morning,weekend_noon,weekend_eve,weekend_night from checkinFin,business where checkinFin.business_id == business.business_id and categories like '%Shoppings%'"); 

checkinShopping.registerTempTable("checkinShopping");


val checkinShopping = sqlContext.sql("select sum(weekday_morning) as weekday_morning,sum(weekday_noon) as weekday_noon, sum(weekday_eve) as weekday_eve, sum(weekday_night) as weekday_night, sum(weekend_morning) as weekend_morning,sum(weekend_noon) as weekend_noon,sum(weekend_eve) as weekend_eve,sum(weekend_night) as weekend_night from checkinShopping "); 

checkinShopping.registerTempTable("checkinShopping");

checkinShopping.show

println("Beauty : ")

val checkinBeauty = sqlContext.sql("select weekday_morning,weekday_noon, weekday_eve, weekday_night, weekend_morning,weekend_noon,weekend_eve,weekend_night from checkinFin,business where checkinFin.business_id == business.business_id and categories like '%Beautys%'"); 

checkinBeauty.registerTempTable("checkinBeauty");


val checkinBeauty = sqlContext.sql("select sum(weekday_morning) as weekday_morning,sum(weekday_noon) as weekday_noon, sum(weekday_eve) as weekday_eve, sum(weekday_night) as weekday_night, sum(weekend_morning) as weekend_morning,sum(weekend_noon) as weekend_noon,sum(weekend_eve) as weekend_eve,sum(weekend_night) as weekend_night from checkinBeauty "); 

checkinBeauty.registerTempTable("checkinBeauty");

checkinBeauty.show

println("Grocery : ")


val checkinGrocery = sqlContext.sql("select weekday_morning,weekday_noon, weekday_eve, weekday_night, weekend_morning,weekend_noon,weekend_eve,weekend_night from checkinFin,business where checkinFin.business_id == business.business_id and categories like '%Grocerys%'"); 

checkinGrocery.registerTempTable("checkinGrocery");


val checkinGrocery = sqlContext.sql("select sum(weekday_morning) as weekday_morning,sum(weekday_noon) as weekday_noon, sum(weekday_eve) as weekday_eve, sum(weekday_night) as weekday_night, sum(weekend_morning) as weekend_morning,sum(weekend_noon) as weekend_noon,sum(weekend_eve) as weekend_eve,sum(weekend_night) as weekend_night from checkinGrocery "); 

checkinGrocery.registerTempTable("checkinGrocery");

checkinGrocery.show


println("Entertainment : ")



val checkinEntertainment = sqlContext.sql("select weekday_morning,weekday_noon, weekday_eve, weekday_night, weekend_morning,weekend_noon,weekend_eve,weekend_night from checkinFin,business where checkinFin.business_id == business.business_id and categories like '%Entertainments%'"); 

checkinEntertainment.registerTempTable("checkinEntertainment");


val checkinEntertainment = sqlContext.sql("select sum(weekday_morning) as weekday_morning,sum(weekday_noon) as weekday_noon, sum(weekday_eve) as weekday_eve, sum(weekday_night) as weekday_night, sum(weekend_morning) as weekend_morning,sum(weekend_noon) as weekend_noon,sum(weekend_eve) as weekend_eve,sum(weekend_night) as weekend_night from checkinEntertainment "); 

checkinEntertainment.registerTempTable("checkinEntertainment");

checkinEntertainment.show


println("Checkin based on city")


val checkincity = sqlContext.sql("select checkin1.business_id , city, weekday_morning, weekday_noon, weekday_eve, weekday_night, weekend_morning, weekend_noon, weekend_eve, weekend_night from business,checkin1 where business.business_id = checkin1.business_id ");

checkincity.registerTempTable("checkincity")

val checkincityFin = sqlContext.sql("select city,sum(weekday_morning) as weekday_morning,sum(weekday_noon) as weekday_noon,sum(weekday_eve) as weekday_eve,sum(weekday_night) as weekday_night,sum(weekend_morning) as weekend_morning,sum(weekend_noon) as weekend_noon, sum(weekend_eve) as weekend_eve ,sum(weekend_night) as weekend_night from checkincity group by city order by weekend_eve desc");

checkincityFin.registerTempTable("checkincityFin");

checkincityFin.show


println("Spring city based :")


al spring = sqlContext.sql("SELECT business.business_id,city, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=3 AND MONTH(date) <=5)  AND (YEAR(date) >=2009)");

spring.registerTempTable("spring");

val spring1 = sqlContext.sql("select business_id,city, case when year = 2009 then COUNT(stars) else 0 end  , case when year = 2010 then COUNT(stars) else 0 end , case when year = 2011 then COUNT(stars) else 0 end , case when year = 2012 then COUNT(stars) else 0 end , case when year = 2013 then COUNT(stars) else 0 end , case when year = 2014 then COUNT(stars) else 0 end , case when year = 2015 then COUNT(stars) else 0  end  from spring group by city, year,business_id");

val newNames = Seq("business_id","city", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val springRenamed = spring1.toDF(newNames: _*)

springRenamed.registerTempTable("springRenamed")

val springFin = sqlContext.sql("select business_id,city , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from springRenamed group by business_id,city");

val springCity = springFin.toDF(newNames: _*)

springCity.registerTempTable("springCity")

springCity.show



println("Summer Based on city :")


val summer = sqlContext.sql("SELECT business.business_id,city, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=6 AND MONTH(date) <=8)  AND (YEAR(date) >=2009)");

summer.registerTempTable("summer");

val summer1 = sqlContext.sql("select business_id,city, case when year = 2009 then COUNT(stars) else 0 end  , case when year = 2010 then COUNT(stars) else 0 end , case when year = 2011 then COUNT(stars) else 0 end , case when year = 2012 then COUNT(stars) else 0 end , case when year = 2013 then COUNT(stars) else 0 end , case when year = 2014 then COUNT(stars) else 0 end , case when year = 2015 then COUNT(stars) else 0  end  from summer group by city,business_id, year");


val newNames = Seq("business_id","city", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val summerRenamed = summer1.toDF(newNames: _*)

summerRenamed.registerTempTable("summerRenamed")

val summerFin = sqlContext.sql("select business_id,city , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from summerRenamed group by business_id,city")

val summerCity = summerFin.toDF(newNames: _*)

summerCity.registerTempTable("summerCity")

summerCity.show


summerCity.show

println("Autumn Based on City")



val autumn = sqlContext.sql("SELECT business.business_id,city, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=9 AND MONTH(date) <=11)  AND (YEAR(date) >=2009)");

autumn.registerTempTable("autumn");

val autumn1 = sqlContext.sql("select business_id,city, case when year = 2009 then COUNT(stars) else 0 end  , case when year = 2010 then COUNT(stars) else 0 end , case when year = 2011 then COUNT(stars) else 0 end , case when year = 2012 then COUNT(stars) else 0 end , case when year = 2013 then COUNT(stars) else 0 end , case when year = 2014 then COUNT(stars) else 0 end , case when year = 2015 then COUNT(stars) else 0  end  from autumn group by city,business_id, year");


val newNames = Seq("business_id","city", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val autumnRenamed = autumn1.toDF(newNames: _*)

autumnRenamed.registerTempTable("autumnRenamed")

val autumnFin = sqlContext.sql("select business_id,city , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from autumnRenamed group by business_id,city")

val autumnCity = autumnFin.toDF(newNames: _*)

autumnCity.registerTempTable("autumnCity")

autumnCity.show


println("Winter Based on city: ")

val winter = sqlContext.sql("SELECT business.business_id,city, review.stars, YEAR(review.date) AS year FROM business , review WHERE business.business_id= review.business_id AND (MONTH(date) >=11 OR MONTH(date) <=2)  AND (YEAR(date) >=2009)");

winter.registerTempTable("winter");

val winter1 = sqlContext.sql("select business_id,city, case when year = 2009 then COUNT(stars) else 0 end  , case when year = 2010 then COUNT(stars) else 0 end , case when year = 2011 then COUNT(stars) else 0 end , case when year = 2012 then COUNT(stars) else 0 end , case when year = 2013 then COUNT(stars) else 0 end , case when year = 2014 then COUNT(stars) else 0 end , case when year = 2015 then COUNT(stars) else 0  end  from winter group by city,business_id, year");


val newNames = Seq("business_id","city", "year1", "year2", "year3", "year4", "year5", "year6","year7")

val winterRenamed = winter1.toDF(newNames: _*)

winterRenamed.registerTempTable("winterRenamed")

val winterFin = sqlContext.sql("select business_id,city , sum(year1), sum(year2),sum(year3),sum(year4),sum(year5),sum(year6),sum(year7) from winterRenamed group by business_id,city")

val winterCity = winterFin.toDF(newNames: _*)

winterCity.registerTempTable("winterCity")



println("Analysis based on city and business type : ")


println("Shopping in Vegas :")


val springShopping = sqlContext.sql("select springCity.business_id, year1,year2,year3,year4,year5,year6,year7 from springCity,business where springCity.business_id=business.business_id and springCity.city like 'Las Vegas' and categories like '%Shopping%'");

springShopping.registerTempTable("springShopping");

val springShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springShopping");

springShopping.registerTempTable("springShopping");

springShopping.show

 val summerShopping = sqlContext.sql("select summerCity.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCity,business where summerCity.business_id=business.business_id and summerCity.city like 'Las Vegas' and categories like '%Shopping%'");

summerShopping.registerTempTable("summerShopping");

val summerShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerShopping");

summerShopping.registerTempTable("summerShopping");

summerShopping.show

 val autumnShopping = sqlContext.sql("select autumnCity.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCity,business where autumnCity.business_id=business.business_id and autumnCity.city like 'Las Vegas' and categories like '%Shopping%'");

autumnShopping.registerTempTable("autumnShopping");

val autumnShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnShopping");

autumnShopping.registerTempTable("autumnShopping");

autumnShopping.show

val winterShopping = sqlContext.sql("select winterCity.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCity,business where winterCity.business_id=business.business_id and winterCity.city like 'Las Vegas' and categories like '%Shopping%'");

 winterShopping.registerTempTable("winterShopping");

val winterShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterShopping");

 winterShopping.registerTempTable("winterShopping");

winterShopping.show


println("Shopping in Montreal :")


val springShopping = sqlContext.sql("select springCity.business_id, year1,year2,year3,year4,year5,year6,year7 from springCity,business where springCity.business_id=business.business_id and springCity.city like 'Montreal' and categories like '%Shopping%'");

springShopping.registerTempTable("springShopping");

val springShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springShopping");

springShopping.registerTempTable("springShopping");

springShopping.show

 val summerShopping = sqlContext.sql("select summerCity.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCity,business where summerCity.business_id=business.business_id and summerCity.city like 'Montreal' and categories like '%Shopping%'");

summerShopping.registerTempTable("summerShopping");

val summerShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerShopping");

summerShopping.registerTempTable("summerShopping");

summerShopping.show

 val autumnShopping = sqlContext.sql("select autumnCity.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCity,business where autumnCity.business_id=business.business_id and autumnCity.city like 'Montreal' and categories like '%Shopping%'");

autumnShopping.registerTempTable("autumnShopping");

val autumnShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnShopping");

autumnShopping.registerTempTable("autumnShopping");

autumnShopping.show

val winterShopping = sqlContext.sql("select winterCity.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCity,business where winterCity.business_id=business.business_id and winterCity.city like 'Montreal' and categories like '%Shopping%'");

 winterShopping.registerTempTable("winterShopping");

val winterShopping=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterShopping");

 winterShopping.registerTempTable("winterShopping");

winterShopping.show


println("Restaurants in Las vegas :")

val springRestaurant = sqlContext.sql("select springCity.business_id, year1,year2,year3,year4,year5,year6,year7 from springCity,business where springCity.business_id=business.business_id and springCity.city like 'Las Vegas' and categories like '%Restaurant%'");

springRestaurant.registerTempTable("springRestaurant");

val springRestaurant=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springRestaurant");

springRestaurant.registerTempTable("springRestaurant");

springRestaurant.show

 val summerRestaurant = sqlContext.sql("select summerCity.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCity,business where summerCity.business_id=business.business_id and summerCity.city like 'Las Vegas' and categories like '%Restaurant%'");

summerRestaurant.registerTempTable("summerRestaurant");

val summerRestaurant=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerRestaurant");

summerRestaurant.registerTempTable("summerRestaurant");

summerRestaurant.show

 val autumnRestaurant = sqlContext.sql("select autumnCity.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCity,business where autumnCity.business_id=business.business_id and autumnCity.city like 'Las Vegas' and categories like '%Restaurant%'");

autumnRestaurant.registerTempTable("autumnRestaurant");

val autumnRestaurant=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnRestaurant");

autumnRestaurant.registerTempTable("autumnRestaurant");

autumnRestaurant.show

val winterRestaurant = sqlContext.sql("select winterCity.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCity,business where winterCity.business_id=business.business_id and winterCity.city like 'Las Vegas' and categories like '%Restaurant%'");

 winterRestaurant.registerTempTable("winterRestaurant");

val winterRestaurant=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterRestaurant");

 winterRestaurant.registerTempTable("winterRestaurant");

winterRestaurant.show

println("Restaurant in Montreal :");

val springRestaurant = sqlContext.sql("select springCity.business_id, year1,year2,year3,year4,year5,year6,year7 from springCity,business where springCity.business_id=business.business_id and springCity.city like 'Montreal' and categories like '%Restaurant%'");

springRestaurant.registerTempTable("springRestaurant");

val springRestaurant=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from springRestaurant");

springRestaurant.registerTempTable("springRestaurant");

springRestaurant.show

 val summerRestaurant = sqlContext.sql("select summerCity.business_id, year1,year2,year3,year4,year5,year6,year7 from summerCity,business where summerCity.business_id=business.business_id and summerCity.city like 'Montreal' and categories like '%Restaurant%'");

summerRestaurant.registerTempTable("summerRestaurant");

val summerRestaurant=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from summerRestaurant");

summerRestaurant.registerTempTable("summerRestaurant");

summerRestaurant.show

 val autumnRestaurant = sqlContext.sql("select autumnCity.business_id, year1,year2,year3,year4,year5,year6,year7 from autumnCity,business where autumnCity.business_id=business.business_id and autumnCity.city like 'Montreal' and categories like '%Restaurant%'");

autumnRestaurant.registerTempTable("autumnRestaurant");

val autumnRestaurant=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from autumnRestaurant");

autumnRestaurant.registerTempTable("autumnRestaurant");

autumnRestaurant.show

val winterRestaurant = sqlContext.sql("select winterCity.business_id, year1,year2,year3,year4,year5,year6,year7 from winterCity,business where winterCity.business_id=business.business_id and winterCity.city like 'Montreal' and categories like '%Restaurant%'");

 winterRestaurant.registerTempTable("winterRestaurant");

val winterRestaurant=sqlContext.sql("select sum(year1) as year1,sum(year2) as year2 , sum(year3) as year3, sum(year4) as year4, sum(year5) as year5, sum(year6) as year6, sum(year7) as year7 from winterRestaurant");

 winterRestaurant.registerTempTable("winterRestaurant");

winterRestaurant.show



















