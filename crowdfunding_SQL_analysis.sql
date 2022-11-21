-- Retrieve all the number of backer_counts in descending order for each `cf_id` for the "live" campaigns. 
SELECT cf_id, backers_count
FROM campaign
WHERE outcome='live'
GROUP BY cf_id
ORDER BY backers_count DESC;


-- Retrieve the same resul from the "backers" table.
SELECT cf_id, COUNT(backer_id)
FROM backers
GROUP BY cf_id
ORDER BY COUNT(backer_id) DESC;

-- Create a table that has the first and last name, and email address of each contact.
-- and the amount left to reach the goal for all "live" projects in descending order. 
SELECT co.first_name, co.last_name, co.email, (ca.goal - ca.pledged) as remaining
INTO email_contacts_remaining_goal_amount
FROM contacts as co
JOIN campaign as ca
	ON co.contact_id = ca.contact_id
WHERE ca.outcome='live'
ORDER BY remaining DESC;

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
