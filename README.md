# Power BI & R Examples from PASS Summit

At PASS Summit 2017, @PatrickDBA and @MrDataGeek gave a presentation demostrating how ways to perform
data wrangling tasks using both Power Query (M) & R. In this repo you will find a RTVS solution that 
contains 6 projects. Those 6 projects are:

* **Advance Calculation**:  Since R is a languge developed by staticians for staticians it lends itself 
to math very easily. In this example I will show how you can use R to perform calculations such as calculating
the distance between 2 geographical points. This calculation would be much harder to do in M. You can also
so this being used in the xxx file in which I called R from GetData and performed the same calculation.

* **Combining Multiple Files**: In this example I show how package such as data.table can be used to combine
multiple files in an efficient way. I also gave examples of how you can leverage regular expression in R
to be more selective with the files you want to combine.

* **Custom Visual**: In this example I showed an example of a visualization that is possible in R that is 
not available in Power BI. The type of visualization I demostrated was a box-violin plot which is a popular
visualization to show data dispersion. I also demostrated how annotations can be added to your R visualizations
to give them more meaning.

* **Date Table**:  Yes another date table! Lol. In this example there is a little twist. I demostrated how
you can use the rvest package to scrape federal holiday data from a website to add as an attribute to your 
date dimension table.

* **Parameterized Queries**: This example was inspired by a video from GuyInACube in which Patrick developed
a M scripts that used a list of data from an Excel file as a parameter to a SQL Server stored procedure. I did 
something similiar using R instead of M.

* **Predict Games**: In this example I showed how you can use an R model saved to disk to score data and bring
add the resulting data set to your Power BI data model. For fun I develop a logistic regression model that
predicted home team wins based on data from the 2008-2009 NBA basketball season. I included the script that was 
used to build the model. I chose the best of 7 models to use in the demostration. Part of the reason why I 
included the script that showed how I built the model was to show that even in simple models a lot of prep work
and data wrangling is needed to build predictive models.

Here is a link to data sets and Power BI files: [Data & Power BI files](https://dieselanalytics-my.sharepoint.com/personal/rwade_dieselanalytics_com/_layouts/15/guestaccess.aspx?folderid=056cf1f64c8064b4da059de5d18f9297d&authkey=AcWmsNF7-nDtoFvdmr7ku9s&e=1f3477bf15e746468518b91a8cc35a26)
