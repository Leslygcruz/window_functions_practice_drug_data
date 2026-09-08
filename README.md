# window_functions_practice_drug_data
week 1 part 2 Best Practices for Writing and Formatting Code

## Week 1, Part 2: Window Functions Practice

1. Using the drug_exposure table, find the first exposure to epoetin alfa (drug_concept_id = 1301125) for each patient. Return all columns from drug_exposure. If a patient has more than one record on their first exposure date, return only the record with the lowest drug_exposure_id. Use a window function in your query.

2. For each patient who received epoetin alfa on more than one day, find the second distinct date on which they received it. Again, return all columns from the drug_exposure table, and if a patient has more than one record on their second exposure date, return only the lowest drug_exposure_id. 

3. For each person, count their visits and rank them within their gender.

4. For each patient, calculate a running total of visits over time, ordered by visit_start_date.

5. Show each patient's total number of different conditions and the average number of conditions across all patients in the same gender.

6. For each gender, count the number of visits in each care setting (visit_concept_id, which can be found in the visit_occurrence table). Compute what percentage of that gender's total visits each care setting represents. Return a table with 4 columns: gender_concept_id, visit_concept_id, visit_count, percent_of_gender_visits (percentage of that gender's total visits for that care setting).

7. For each patient, identify inpatient or emergency visits that occur less than 30 days after the previous visit. These could indicate possible readmissions. Inpatient and emergency visits can be found using visit_concept_ids 9201 and 9203. 

8. Rank the top five providers based on the total count of procedures (procedure_occurrence_id) they documented. Which ranking function did you use, and why did you choose that one vs another choice?
