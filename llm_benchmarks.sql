-- Step 1: Table Creation
CREATE TABLE llm_benchmarks (
    model_name VARCHAR(100),
    country VARCHAR(50),
    parameters_b DECIMAL(10,2),
    overall_benchmark_avg DECIMAL(5,2),
    performance_per_dollar DECIMAL(10,2),
    speed_tok_s DECIMAL(10,2),
    open_source VARCHAR(10),
    reasoning_model VARCHAR(10),
    multimodal VARCHAR(10),
    price_tier VARCHAR(20)
);

-- Step 2: Data Import (adjust path to your CSV file)
LOAD DATA INFILE 'C:/path/to/llm_benchmarks.csv'
INTO TABLE llm_benchmarks
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(model_name, country, @parameters_b, @overall_benchmark_avg, @performance_per_dollar, @speed_tok_s,
 open_source, reasoning_model, multimodal, price_tier)
SET parameters_b = NULLIF(@parameters_b, ''),
    overall_benchmark_avg = NULLIF(@overall_benchmark_avg, ''),
    performance_per_dollar = NULLIF(@performance_per_dollar, ''),
    speed_tok_s = NULLIF(@speed_tok_s, '');

-- Step 3: Verify Import
SELECT COUNT(*) AS total_rows FROM llm_benchmarks;
SELECT * FROM llm_benchmarks LIMIT 5;

-- Step 4: Exploration Queries
-- Top models by benchmark score
SELECT model_name, overall_benchmark_avg
FROM llm_benchmarks
ORDER BY overall_benchmark_avg DESC
LIMIT 5;

-- Budget leaders (performance per dollar)
SELECT model_name, performance_per_dollar
FROM llm_benchmarks
ORDER BY performance_per_dollar DESC
LIMIT 5;

-- Fastest speed tier models
SELECT model_name, speed_tok_s
FROM llm_benchmarks
ORDER BY speed_tok_s DESC
LIMIT 5;

-- Reasoning models above 85 score
SELECT model_name, overall_benchmark_avg
FROM llm_benchmarks
WHERE reasoning_model = 'True' AND overall_benchmark_avg > 85;

-- Country-wise average benchmark
SELECT country, AVG(overall_benchmark_avg) AS avg_score
FROM llm_benchmarks
GROUP BY country
ORDER BY avg_score DESC;

-- Step 5: Stored Procedure
DROP PROCEDURE IF EXISTS GetTopModels;
DELIMITER //
CREATE PROCEDURE GetTopModels(IN metric VARCHAR(50))
BEGIN
    SET @sql = CONCAT(
        'SELECT model_name, ', metric,
        ' FROM llm_benchmarks ORDER BY ', metric, ' DESC LIMIT 5;'
    );
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- Step 6: View for Reporting
CREATE OR REPLACE VIEW performance_vs_cost AS
SELECT model_name, overall_benchmark_avg, performance_per_dollar, price_tier
FROM llm_benchmarks
ORDER BY performance_per_dollar DESC;

-- Step 7: Trigger for Logging Inserts
CREATE TABLE IF NOT EXISTS model_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(100),
    action VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS log_model_insert;
DELIMITER //
CREATE TRIGGER log_model_insert
AFTER INSERT ON llm_benchmarks
FOR EACH ROW
BEGIN
    INSERT INTO model_log (model_name, action)
    VALUES (NEW.model_name, 'INSERT');
END //
DELIMITER ;

-- Step 8: Advanced Analysis Queries
-- Best reasoning models above 85 score
SELECT model_name, overall_benchmark_avg
FROM llm_benchmarks
WHERE reasoning_model = 'True' AND overall_benchmark_avg > 85
ORDER BY overall_benchmark_avg DESC;

-- Top multimodal models by speed
SELECT model_name, speed_tok_s
FROM llm_benchmarks
WHERE multimodal = 'True'
ORDER BY speed_tok_s DESC
LIMIT 5;

-- Country contribution by count
SELECT country, COUNT(*) AS model_count
FROM llm_benchmarks
GROUP BY country
ORDER BY model_count DESC;
