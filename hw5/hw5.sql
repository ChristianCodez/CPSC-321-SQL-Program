/*======================================================================
 * 
*  NAME:    Christian Carrington
*  ASSIGN:  HW-3, Part 1
*  COURSE:  CPSC 321, Fall 2025
*  DESC:    Defines and populates a PostgreSQL schema based on the CIA World Factbook.
*           Includes tables for Country, Province, City, and Border with keys and constraints.
*           Populates with 4 countries, 4 provinces per country, 4 cities per province, and 2 borders.
* 
*======================================================================*/


-- TODO:
--   * Fill in your name above and a brief description.
--   * Implement the Part 1 schema as per the homework instructions.
--   * Populate each table according to the homework instructions.
--   * Be sure each table has a comment describing its purpose.
--   * Be sure to add comments as needed for attributes.
--   * Be sure your SQL code is well formatted (according to the style guides).

DROP TABLE IF EXISTS Border;
DROP TABLE IF EXISTS City;
DROP TABLE IF EXISTS Province;
DROP TABLE IF EXISTS Country;


CREATE TABLE Country (
    country_code    CHAR(2),
    country_name    VARCHAR(75) NOT NULL,
    gdp             INT NOT NULL,
    inflation       NUMERIC NOT NULL,

    PRIMARY KEY (country_code),
    CONSTRAINT check_inflation CHECK (inflation > -100.0),
    CONSTRAINT check_gdp CHECK (gdp > 0)
);

CREATE TABLE Province (
    province_name   VARCHAR(100),
    country_code    CHAR(2),
    area            NUMERIC NOT NULL,

    PRIMARY KEY (province_name, country_code),
    FOREIGN KEY (country_code) REFERENCES Country(country_code),
    CONSTRAINT check_area CHECK (area > 0.0)
);

CREATE TABLE City (
    city_name       VARCHAR(100),
    province_name   VARCHAR(100),
    country_code    CHAR(2),
    population      INT NOT NULL,

    PRIMARY KEY (city_name, province_name, country_code),
    FOREIGN KEY (province_name, country_code) REFERENCES Province(province_name, country_code),
    CONSTRAINT check_pop CHECK (population > 0)
);

CREATE TABLE Border (
    country_code_1      CHAR(2),
    country_code_2      CHAR(2),
    border_length       INT NOT NULL,

    PRIMARY KEY (country_code_1, country_code_2),
    FOREIGN KEY (country_code_1) REFERENCES Country(country_code),
    FOREIGN KEY (country_code_2) REFERENCES Country(country_code),
    CONSTRAINT  border_length_check CHECK (border_length > 0),
    -- forces not equal and no dups with borders
    CONSTRAINT check_country_order CHECK (country_code_1 < country_code_2) 
);


-- ---------- INSERTS ----------

-- COUNTRY TABLES (4 countries)
INSERT INTO Country (country_code, country_name, gdp, inflation) VALUES
    ('RW', 'Republic of Weldwood', 45000, 2.5),
    ('SK', 'Sovereignty of Kindra', 82000, 1.8),
    ('AG', 'Archduchy of Glacia', 110000, 0.9),
    ('VB', 'Volcanic Baronies', 31000, 7.3);

SELECT *
FROM Country;


-- PROVINCE TABLES (4 provinces per country)
-- Provinces for Weldwood ('RW')
INSERT INTO Province (province_name, country_code, area) VALUES
    ('The Amber Forest', 'RW', 50210.5),
    ('Riverlands', 'RW', 35100.2),
    ('Greenstone Hills', 'RW', 41500.0),
    ('Coastal Plains', 'RW', 62300.8);

-- Provinces for Kindra ('SK')
INSERT INTO Province (province_name, country_code, area) VALUES
    ('Sunstone Plateau', 'SK', 120400.0),
    ('Golden Savannah', 'SK', 250000.5),
    ('Ruby Desert', 'SK', 310200.0),
    ('Emerald Oasis', 'SK', 15000.7);

-- Provinces for Glacia ('AG')
INSERT INTO Province (province_name, country_code, area) VALUES
    ('Frostpeak Mountains', 'AG', 95000.0),
    ('Northern Tundra', 'AG', 180600.2),
    ('Crystal Fjordlands', 'AG', 75320.9),
    ('Icebound Coast', 'AG', 110000.0);

-- Provinces for the Volcanic Baronies ('VB')
INSERT INTO Province (province_name, country_code, area) VALUES
    ('Ashfall Peaks', 'VB', 65000.0),
    ('Magma Fields', 'VB', 89300.5),
    ('The Cinderlands', 'VB', 105000.0),
    ('Obsidian Shore', 'VB', 45200.3);

SELECT *
FROM Province;


--- CITY TABLES (16 cities per country)
-- Cities for Weldwood ('RW')
INSERT INTO City (city_name, province_name, country_code, population) VALUES
    ('Oakheart', 'The Amber Forest', 'RW', 85000),
    ('Sylvanrest', 'The Amber Forest', 'RW', 32000),
    ('Timberfall', 'The Amber Forest', 'RW', 48000),
    ('Rootwatch', 'The Amber Forest', 'RW', 12500),
    ('Riverbend', 'Riverlands', 'RW', 250000),
    ('Fordbridge', 'Riverlands', 'RW', 75000),
    ('Clearwater', 'Riverlands', 'RW', 92000),
    ('Kingsflow', 'Riverlands', 'RW', 180000),
    ('Stonehaven', 'Greenstone Hills', 'RW', 110000),
    ('Grasmere', 'Greenstone Hills', 'RW', 45000),
    ('Hilltop', 'Greenstone Hills', 'RW', 22000),
    ('Greenmeadow', 'Greenstone Hills', 'RW', 89000),
    ('Port Amber', 'Coastal Plains', 'RW', 320000),
    ('Seaside', 'Coastal Plains', 'RW', 150000),
    ('Bayview', 'Coastal Plains', 'RW', 95000),
    ('Saltwind', 'Coastal Plains', 'RW', 68000);

-- Cities for Kindra ('SK')
INSERT INTO City (city_name, province_name, country_code, population) VALUES
    ('Solara', 'Sunstone Plateau', 'SK', 450000),
    ('Suncrest', 'Sunstone Plateau', 'SK', 120000),
    ('Mesa Verde', 'Sunstone Plateau', 'SK', 88000),
    ('Highpoint', 'Sunstone Plateau', 'SK', 62000),
    ('Lions Gate', 'Golden Savannah', 'SK', 310000),
    ('Acacia Grove', 'Golden Savannah', 'SK', 78000),
    ('Goldendust', 'Golden Savannah', 'SK', 45000),
    ('Savannahs Heart', 'Golden Savannah', 'SK', 195000),
    ('Crimson Oasis', 'Ruby Desert', 'SK', 95000),
    ('Sandfire', 'Ruby Desert', 'SK', 25000),
    ('Ruby Spire', 'Ruby Desert', 'SK', 140000),
    ('Dunes End', 'Ruby Desert', 'SK', 15000),
    ('Emeraldwater', 'Emerald Oasis', 'SK', 210000),
    ('Palm City', 'Emerald Oasis', 'SK', 180000),
    ('Verde Springs', 'Emerald Oasis', 'SK', 99000),
    ('Jewel of Kindra', 'Emerald Oasis', 'SK', 350000);

-- Cities for Glacia ('AG')
INSERT INTO City (city_name, province_name, country_code, population) VALUES
    ('Skyfrost', 'Frostpeak Mountains', 'AG', 75000),
    ('Glaciers Peak', 'Frostpeak Mountains', 'AG', 22000),
    ('Icehelm', 'Frostpeak Mountains', 'AG', 180000),
    ('Winterhold', 'Frostpeak Mountains', 'AG', 110000),
    ('Northwind', 'Northern Tundra', 'AG', 45000),
    ('Tundratown', 'Northern Tundra', 'AG', 18000),
    ('White Wastes', 'Northern Tundra', 'AG', 9500),
    ('Aurora Village', 'Northern Tundra', 'AG', 32000),
    ('Fjordport', 'Crystal Fjordlands', 'AG', 280000),
    ('Crystalharbor', 'Crystal Fjordlands', 'AG', 160000),
    ('Deepwater', 'Crystal Fjordlands', 'AG', 85000),
    ('Icegate', 'Crystal Fjordlands', 'AG', 190000),
    ('Sea of Ice', 'Icebound Coast', 'AG', 130000),
    ('Coastwatch', 'Icebound Coast', 'AG', 65000),
    ('Frosthaven', 'Icebound Coast', 'AG', 240000),
    ('Shipwreck Bay', 'Icebound Coast', 'AG', 40000);

-- Cities for the Volcanic Baronies ('VB')
INSERT INTO City (city_name, province_name, country_code, population) VALUES
    ('Cinderfort', 'Ashfall Peaks', 'VB', 120000),
    ('Ashmont', 'Ashfall Peaks', 'VB', 65000),
    ('Blackrock', 'Ashfall Peaks', 'VB', 95000),
    ('Smokefall', 'Ashfall Peaks', 'VB', 48000),
    ('Lavaport', 'Magma Fields', 'VB', 210000),
    ('Caldera', 'Magma Fields', 'VB', 150000),
    ('Fireflow', 'Magma Fields', 'VB', 80000),
    ('Molten City', 'Magma Fields', 'VB', 300000),
    ('Cindertown', 'The Cinderlands', 'VB', 78000),
    ('Ashgard', 'The Cinderlands', 'VB', 115000),
    ('Ember Post', 'The Cinderlands', 'VB', 35000),
    ('The Kiln', 'The Cinderlands', 'VB', 55000),
    ('Glassport', 'Obsidian Shore', 'VB', 180000),
    ('Obsidian Edge', 'Obsidian Shore', 'VB', 99000),
    ('Volcanic Bay', 'Obsidian Shore', 'VB', 130000),
    ('Darktide', 'Obsidian Shore', 'VB', 60000);

SELECT *
FROM City;

-- BORDERS
INSERT INTO Border (country_code_1, country_code_2, border_length) VALUES
    ('AG', 'SK', 2450),
    ('RW', 'SK', 1880), 
    ('AG', 'RW', 975),
    ('AG', 'VB', 1400),
    ('RW', 'VB', 480),
    ('SK', 'VB', 1170);

SELECT *
FROM Border;