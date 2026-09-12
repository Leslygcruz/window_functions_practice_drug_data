--1. Using the drug_exposure table, find the first exposure to epoetin alfa (drug_concept_id = 1301125)
--for each patient. Return all columns from drug_exposure. If a patient has more than one record on their 
--first exposure date, return only the record with the lowest drug_exposure_id. Use a window function in --
--your query.
WITH first_exp_date AS(SELECT person_id, MIN(drug_exposure_start_date) AS first_date
						FROM drug_exposure
						WHERE drug_concept_id = 1301125 
						GROUP BY person_id), 
epo_alfa AS(SELECT de.*,
				COUNT(drug_exposure_start_date) OVER (
					PARTITION BY person_id) AS num_of_exposures
			FROM drug_exposure AS de
			WHERE drug_concept_id = 1301125)
SELECT *
FROM epo_alfa AS ea
	INNER JOIN first_exp_date AS fed
	ON ea.person_id = fed.person_id AND ea.drug_exposure_start_date = fed.first_date
WHERE ea.num_of_exposures > 1
ORDER BY ea.drug_exposure_id ASC
LIMIT 1;
--min()
/*WITH drug_expo_count(SELECT personid, COUNT(drug_exposure_start_date) AS num_of_exposures
					FROM drug_exposure
					WHERE num_of_exposures> )
SELECT *
FROM drug_exposure
LIMIT 5 */
/*
2. For each patient who received epoetin alfa on more than one day, 
find the second distinct date on which they received it. 
Again, return all columns from the drug_exposure table, 
and if a patient has more than one record on their second exposure date, 
return only the lowest drug_exposure_id. */
WITH sec_min_date AS (SELECT DISTINCT drug_exposure_start_date AS second_date
						FROM drug_exposure
						ORDER BY drug_exposure_start_date
						LIMIT 1 OFFSET 1),
epo_alfa AS(SELECT *,
			COUNT(drug_exposure_start_date) OVER(
				PARTITION BY person_id) AS num_of_exposures
			FROM drug_exposure)
SELECT *
FROM epo_alfa AS ea
	INNER JOIN sec_min_date AS smd
	ON ea.drug_exposure_start_date = smd.second_date
WHERE ea.num_of_exposures > 1 AND drug_concept_id = 1301125
ORDER BY ea.drug_exposure_id ASC
LIMIT 1;

/*3. For each person, count their visits and rank them within their gender.*/
SELECT vo.person_id, p.gender_concept_id, COUNT(vo.visit_occurrence_id) AS visit_count,
	RANK() OVER
	PARTITION BY p.gender_concept_id
	ORDER BY COUNT(vo.visit_occurrence_id) DESC
	) AS visit_rank
FROM visit_occurrence AS vo
LEFT JOIN person AS p
ON p.person_id = vo.person_id
GROUP BY vo.person_id, p.gender_concept_id;

/*4.For each patient, calculate a running total of visits over time, ordered by visit_start_date.*/
SELECT DISTINCT person_id, visit_start_date,
	COUNT(visit_occurrence_id)
	OVER (ORDER BY visit_start_date) AS running_total_of_visits
FROM visit_occurrence;

/*5.Show each patient’s total number of different conditions 
and the average number of conditions across all patients in the same gender.*/
SELECT co.person_id, p.gender_concept_id,
	AVG(co.condition_concept_id) OVER(
	PARTITION BY p.gender_concept_id
	) AS avg_condition_per_gender,
	COUNT(co.condition_concept_id) OVER(
	PARTITION BY co.person_id
	) AS num_of_conditions
FROM condition_occurrence AS co
	INNER JOIN person AS p
	ON co.person_id = p.person_id;

/*6.For each gender, count the number of visits in each care setting
(visit_concept_id, which can be found in the visit_occurrence table). 
Compute what percentage of that gender’s total visits each care setting represents. 
Return a table with 4 columns: gender_concept_id, visit_concept_id, visit_count, 
percent_of_gender_visits (percentage of that gender’s total visits for that care setting). */
SELECT DISTINCT p.gender_concept_id, 
	COUNT(vo.visit_concept_id) OVER(
	PARTITION BY p.gender_concept_id ) AS num_visits_per_gender,
	AVG(visit_concept_id) OVER(
	PARTITION BY p.gender_concept_id ) AS avg_num_of_visits_per_gender
FROM person AS p
	INNER JOIN visit_occurrence AS vo
	ON p.person_id = vo.person_id;

/*7.For each patient, identify inpatient or emergency visits that occur less than 30 days
after the previous visit. These could indicate possible readmissions.
Inpatient and emergency visits can be found using visit_concept_ids 9201 and 9203. */
WITH visits AS(SELECT *,
		--prior date of individual
			LAG(visit_start_date) OVER (
			PARTITION BY person_id
			ORDER BY visit_start_date ASC
			) AS prev_date,
		--calc diff in day
			(visit_start_date-LAG(visit_start_date) OVER(
				PARTITION BY person_id
				ORDER BY visit_start_date
			)) AS days_between_visits
		FROM visit_occurrence)
SELECT person_id, visit_start_date, prev_date, days_between_visits
FROM visits
WHERE (visit_concept_id = 9201 OR visit_concept_id = 9203) AND days_between_visits < 30;

/*8. Rank the top five providers based on the total count of procedures (procedure_occurrence_id)
they documented. Which ranking function did you use, and why did you choose that one vs another 
choice? */
SELECT provider_id, COUNT(procedure_occurrence_id) AS num_of_procedures,
    RANK() OVER (
       --PARTITION BY provider_id --creates a separte ranking for each provider (ranking privder vs himslef)
        ORDER BY COUNT(procedure_occurrence_id) DESC
    ) AS top_procedure_provider
FROM procedure_occurrence
WHERE provider_id IS NOT NULL
GROUP BY provider_id
ORDER BY top_procedure_provider 
LIMIT 5;

