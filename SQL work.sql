CREATE DATABASE Credit_Scoring_Model;
USE Credit_Scoring_Model;
-- Add the customer_id column
ALTER TABLE cleaned_main_dataset
ADD COLUMN customer_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;
SELECT * FROM cleaned_main_dataset;
ALTER TABLE cleaned_main_dataset
CHANGE `Credit.Decision` subscription_status VARCHAR(10);
CREATE TABLE Borrowers (
    customer_id INT PRIMARY KEY,
    age INT,
    job VARCHAR(100),
    marital VARCHAR(50),
    education VARCHAR(50),
    FOREIGN KEY (customer_id) REFERENCES Cleaned_Main_Dataset(customer_id)
);
CREATE TABLE Loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    balance INT,
    housing VARCHAR(10),
    loan VARCHAR(10),
    default_status VARCHAR(10),
    FOREIGN KEY (customer_id) REFERENCES Cleaned_Main_Dataset(customer_id)
);
ALTER TABLE Loans
ADD COLUMN education VARCHAR(50);

CREATE TABLE Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    duration INT,
    campaign INT,
    pdays INT,
    previous INT,
    subscription_status VARCHAR(20),
    days_since_last_contact INT,
    FOREIGN KEY (customer_id) REFERENCES Cleaned_Main_Dataset(customer_id)
);
-- Fill Borrowers
INSERT INTO Borrowers (customer_id, age, job, marital, education)
SELECT customer_id, age, job, marital, education
FROM Cleaned_Main_Dataset;

-- Fill Loans
INSERT INTO Loans (customer_id, balance, education,housing, loan, default_status)
SELECT customer_id, balance, housing, loan, default_status
FROM Cleaned_Main_Dataset;
INSERT INTO Loans(education)
SELECT education FROM Cleaned_Main_Dataset;

-- Fill Payments
INSERT INTO Payments (customer_id, duration, campaign, pdays, previous, subscription_status)
SELECT customer_id, duration, campaign, pdays, previous, subscription_status
FROM Cleaned_Main_Dataset;

#Count of Defaults by Grade (Education) and Income Bracket (Assume Balance Groups)
SELECT 
    education AS grade,
    CASE
        WHEN balance < 0 THEN 'Very Low'
        WHEN balance BETWEEN 0 AND 1000 THEN 'Low'
        WHEN balance BETWEEN 1001 AND 5000 THEN 'Medium'
        ELSE 'High'
    END AS income_bracket,
    COUNT(*) AS default_count
FROM Loans
WHERE default_status = 'yes'
GROUP BY grade, income_bracket;

#Average repayment time per borrower
SELECT 
    customer_id,
    ROUND(AVG(duration), 2) AS avg_repayment_duration
FROM Payments
GROUP BY customer_id
ORDER BY avg_repayment_duration DESC;

#Default rate by employment type
SELECT 
    job AS employment_type,
    COUNT(*) AS total_loans,
    SUM(CASE WHEN LOWER(default_status) = 'yes' THEN 1 ELSE 0 END) AS defaults,
    ROUND(100.0 * SUM(CASE WHEN LOWER(default_status) = 'yes' THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate_percent
FROM Loans
JOIN Borrowers USING(customer_id)
GROUP BY employment_type
ORDER BY default_rate_percent DESC;















   
   
   


