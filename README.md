# Power BI & R Examples from PASS Summit

At PASS Summit 2017, @PatrickDBA and @MrDataGeek gave a presentation demonstrating ways to perform data wrangling tasks using both Power Query (M) & R. In this repo you will find a RTVS solution that contains 6 projects. Here is a brief description of each of those projects:

* **Advance Calculation**:  Since R is a language developed by statistician for statistician it lends itself to math very easily. In this example I showed how you can use R to perform calculations such as calculating the distance between 2 geographical points. This calculation would be much harder to do in M. You can also so this being used in the PowerBI_And_R_Examples pbix file in which I called R from GetData to performed the same calculation.

* **Combining Multiple Files**: In this example I show how the data.table package can be used to combine multiple files in an efficient way. I also gave examples of how you can leverage regular expression in R to be more selective with the files you want to combine.

* **Custom Visual**: In this example I showed an example of a visualization that is possible in R that is not available in Power BI. The type of visualization I demonstrated was a box-violin plot which is a popular visualization to show data dispersion. I also demonstrated how annotations can be added to your R visualizations to give them more meaning. You can view the Demo_TradeBalance pbix file to see how to implement in Power BI.

* **Date Table**:  Yes another date table! Lol. In this example there is a little twist. I demonstrated how you can use the rvest package to scrape federal holiday data from a website to add as an attribute to your date dimension table.

* **Parameterized Queries**: This example was inspired by a video from GuyInACube in which Patrick developed a M scripts that used a list of data from an Excel file as a parameter to a SQL Server stored procedure. I did something similar using R instead of M.

* **Predict Games**: In this example I showed how you can use an R model saved to disk to score data then bring the resulting data set to your Power BI data model. For fun I develop a logistic regression model that predicted home team wins based on data from the 2008-2009 NBA basketball season. I included the script that was used to build the model. I chose the best of 7 models to use in the demonstration. Part of the reason why I included the script used to develop the model was to show that even simple models involvles a lot of prep work and data wrangling to get your data in the proper shape for your predictive models.

Here is a link to data sets and Power BI files: [Data & Power BI files](https://dieselanalytics-my.sharepoint.com/personal/rwade_dieselanalytics_com/_layouts/15/guestaccess.aspx?folderid=056cf1f64c8064b4da059de5d18f9297d&authkey=AcWmsNF7-nDtoFvdmr7ku9s&e=1f3477bf15e746468518b91a8cc35a26)
