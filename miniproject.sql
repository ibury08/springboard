/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
select name from Facilities where membercost>0
Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court



/* Q2: How many facilities do not charge a fee to members? */
select count(*) from Facilities where membercost=0
4


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
select facid,name,membercost,monthlymaintenance from Facilities where membercost>0 and (membercost / monthlymaintenance)<0.2

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
select * from Facilities where facid in(1,5)


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
select name, monthlymaintenance, case when monthlymaintenance > 100 then 'expensive' else 'cheap' end as type from Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
select firstname, surname from Members where joindate = (select max(joindate) from Members)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

select name,`fullname` from(
select memid,name from
(SELECT facid,name FROM `Facilities` where name like 'Tennis%') as A
Join (select * from Bookings) as B on A.facid=B.facid group by memid,name) as C
join (select concat(firstname , ' ' , surname )as `fullname`,memid from Members) as D on C.memid = D.memid order by fullname asc

*This give multiple entries if a member has visited more than one court. If you want just one entry per member regardless of court used,
you can change line 1 from 'Select name, `fullname` from(' to 'Select distinct `fullname` from ('


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT name, full_name, 
CASE WHEN A.memid !=0
THEN membercost * slots
ELSE guestcost * slots
END AS total_cost
FROM (

SELECT * 
FROM Bookings
WHERE DATE( starttime ) =  '2012-09-14'
) AS A
JOIN (

SELECT * 
FROM Facilities
) AS B ON A.facid = B.facid
JOIN (

SELECT CONCAT( firstname,  ' ', surname ) AS full_name, memid
FROM Members
) AS C ON A.memid = C.memid
HAVING total_cost >30
ORDER BY total_cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT name, guestcost * guest_slots + membercost * mem_slots AS revenue
FROM (

SELECT facid, SUM( 
CASE WHEN memid =0
THEN slots
ELSE 0 
END ) AS guest_slots, SUM( 
CASE WHEN memid !=0
THEN slots
ELSE 0 
END ) AS mem_slots
FROM Bookings
GROUP BY facid
) AS A
JOIN (

SELECT * 
FROM Facilities
) AS B ON A.facid = B.facid
ORDER BY revenue DESC