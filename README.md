# Crowdfunding ETL
## Overview
I assisted a crowdfunding platform in transferring all its accessible data from one large excel spreadsheet file into an SQL database to allow analysis.  The excel file had two separate worksheets with campaign and contact information.

## Resources
***Data Source***: crowdfunding.xlsx, backer_info.csv

***Software***: Python 3.7.13, Pandas, Jupyter Notebook, PostgreSQL11, pgAdmin4

## Results
When given the excel file for the Extraction process, I noticed the campaign information could be disaggregated by category and subcategory and some of the headers could use work. Here is a sample of the raw data for the campaigns:

![image](https://github.com/jakatz87/Crowdfunding-ETL/blob/main/Excel%20File%20Sample.png)

Writing the following code, I was able to create IDs for category and subcategory:

```
#Create arrays to assign to each new list with a range to match the numbers
#The upper bound is not included
category_ids=np.arange(1,10)
subcategory_ids=np.arange(1,25)
#Use list comprehension to assign cat0 and scat0 ids
cat_ids=["cat0"+str(cat_id) for cat_id in category_ids]
scat_ids=["scat0"+str(scat_id) for scat_id in subcategory_ids]
#Time to create the category and subcategory DataFrames with needed columns
category_df=pd.DataFrame({
    "category_id":cat_ids,
    "category":categories
})
subcategory_df=pd.DataFrame({
    "subcategory_id": scat_ids,
    "subcategory":subcategories
})
```
I also wanted to get the contact ID from the contact sheet into the campaign dataframe. 

```
#Prepare to add a contact ID from the contact info DataFrame
contact_info_df.head()
#Create a list of values 
contact_info_list=contact_info_df.contact_info.to_list()
#Get this list of ids into the campaign_cleaned_df.
campaign_cleaned["contact_id"]=[x[15:19] for x in contact_info_df["contact_info"].values]
campaign_cleaned.head()
```

I created an updated campaign csv file that had much more manageable data:

![image](https://github.com/jakatz87/Crowdfunding-ETL/blob/main/Created%20campaign%20sample.png)

Working with a similar process, I had to convert the original contact info from the excel file:

![image](https://github.com/jakatz87/Crowdfunding-ETL/blob/main/Raw%20contact%20info%20sample.png)

This involved some JSON work:

```
#Iterate through all the rows to convert to a dictionary and add the values to a list
dict_values=[]
for i, row in contact_info_df.iterrows():
    #pull the data from the contact_info column and convert it with json.loads
    data=row['contact_info']
    converted_data=json.loads(data)
    #Iterate through each row and get the values with list comprehension
    row_values=[v for k, v in converted_data.items()]
    #Append the list of values for each row to a new list
    dict_values.append(row_values)
#Add each of these lists as a new row with the column names "contact_id", "name", "email".
contacts_df=pd.DataFrame(dict_values, columns=['contact_id', 'name', 'email'])
contacts_df.head()
 ```
I created an updated contacts csv file:
![image](https://github.com/jakatz87/Crowdfunding-ETL/blob/main/Created%20contact%20sample.png)

## Summary
With the Transform and Load process completed, I was able to allow the company to begin analyzing data with SQL queries with the backer_info.csv file. 

I wanted to see which campaigns were still live and needed to be finished:
```
-- Create a table that has the first and last name, and email address of each contact.
-- and the amount left to reach the goal for all "live" projects in descending order. 
SELECT co.first_name, co.last_name, co.email, (ca.goal - ca.pledged) as remaining
INTO email_contacts_remaining_goal_amount
FROM contacts as co
JOIN campaign as ca
	ON co.contact_id = ca.contact_id
WHERE ca.outcome='live'
ORDER BY remaining DESC;
```

With this information, the company can assist wrapping up 14 campaigns:
![image](https://github.com/jakatz87/Crowdfunding-ETL/blob/main/live_campaigns_remaining.png)

I also wanted to assist in fundraising efforts, so I needed to find out which campaign backers needed additional nudges for fundraising efforts:
```
-- Create a table, "email_backers_remaining_goal_amount" that contains the email address of each backer in descending order, 
-- and has the first and last name of each backer, the cf_id, company name, description, 
-- end date of the campaign, and the remaining amount of the campaign goal as "Left of Goal". 

SELECT b.email, b.first_name, b.last_name, ca.cf_id, ca.company_name, ca.description, ca.end_date, (ca.goal - ca.pledged) as "Left of Goal"
INTO email_backers_remaining_goal_amount
FROM campaign as ca
JOIN backers as b
	ON ca.cf_id = b.cf_id
WHERE ca.outcome='live'
ORDER BY b.email DESC;
```

I gave the company necessary information to finish the 14 campaigns successfully:
![image](https://github.com/jakatz87/Crowdfunding-ETL/blob/main/backers_to_contact.png)
