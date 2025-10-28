'''
/*======================================================================
 * 
*  NAME:    Christian Carrington
*  ASSIGN:  HW-5, Part 1
*  COURSE:  CPSC 321, Fall 2025
*  DESC:    This program gives a user 7 different options with each option 
*           either halting the program, querying the database for specific 
*           information, or to edit the database.
* 
*======================================================================*/
'''


import psycopg as pg
import config


def show_main_menu():
    """Prints the main menu and gets a validated user choice."""
    print("\n" + "="*30)
    print("  CIA World Factbook Menu")
    print("="*30)
    print("1. List countries")
    print("2. Add country")
    print("3. Add border")
    print("4. Find countries based on gdp and inflation")
    print("5. Update country's gdp and inflation")
    print("6. Remove border")
    print("7. Exit")
    print("-"*30)
    
    while True:
        choice = input("Enter your choice (1-7): ")
        if choice in ['1', '2', '3', '4', '5', '6', '7']:
            return choice
        else:
            print("Invalid choice. Please enter a number between 1 and 7.")


# (Menu 1) Displays all countries in the database.
def list_countries(cn):

    print("\n--- List of Countries ---")
    # this should fetch all the information we need
    q = "SELECT * FROM Country;"
    
    with cn.cursor() as rs:
        rs.execute(q)
        rows = rs.fetchall()
        
        if not rows:
            print("No countries found in the database.")
            return

        for row in rows:
            code, name, gdp, inflation = row
            print(f"{name} ({code}), per capita gdp ${gdp}, inflation rate {inflation}%")


#(Menu 2) Adds a new country to the database.
def add_country(cn):

    print("\n--- Add New Country ---")
    
    code = input("Country code..................: ").upper()
    name = input("Country name..................: ")
    gdp = int(input("Country per capita gdp (USD)..: "))
    inflation = float(input("Country inflation (pct).......: "))
    
    # handles commit and provides a rollback function
    with cn.transaction():
        with cn.cursor() as rs:
            # (a) Check if country code already exists
            q = "SELECT country_code FROM Country WHERE country_code = %s;"
            rs.execute(q, (code,))
            if rs.fetchone():
                # (c) Notify user
                print(f"\nError: Country with code '{code}' already exists.")
            else:
                # (b) Add the country
                q = "INSERT INTO Country (country_code, country_name, gdp, inflation) VALUES (%s, %s, %s, %s);"
                
                rs.execute(q, (code, name, gdp, inflation))
                print(f"\nSuccess: Country '{name} ({code})' added to the database.")


# (Menu 3) Adds a new border to the database.
def add_border(cn):
    print("\n--- Add New Border ---")

    code1 = input("Country code 1..: ").upper()
    code2 = input("Country code 2..: ").upper()
    length = int(input("Border length...: "))
    
    if code1 == code2:
        print("Error: A country cannot border itself.")
        return

    with cn.transaction():
        with cn.cursor() as rs:
            # (a) Check if border exists (in either direction)
            q = """
                SELECT * FROM Border
                WHERE (country_code_1 = %s AND country_code_2 = %s)
                    OR (country_code_1 = %s AND country_code_2 = %s);
            """
            rs.execute(q, (code1, code2, code2, code1))
            if rs.fetchone():
                # (c) Notify user
                print(f"\nError: Border between '{code1}' and '{code2}' already exists.")
            else:
                # (b) Add the border
                if code1 > code2:
                    code1, code2 = code2, code1
                
                q = "INSERT INTO Border (country_code_1, country_code_2, border_length) VALUES (%s, %s, %s);"
                
                rs.execute(q, (code1, code2, length))
                print(f"\nSuccess: Border between '{code1}' and '{code2}' added.")

#(Menu 4) Finds countries within specified gdp/inflation ranges.
def find_countries(cn):
    
    print("\n--- Find Countries by GDP and Inflation ---")
    
    min_gdp = int(input("Minimum per capita gdp (USD)..: "))
    max_gdp = int(input("Maximum per capita gdp (USD)..: "))
    min_inf = float(input("Minimum inflation (pct).......: "))
    max_inf = float(input("Maximum inflation (pct).......: "))
    

    q = """
        SELECT country_name, country_code, gdp, inflation FROM Country
        WHERE (gdp BETWEEN %s AND %s)
            AND (inflation BETWEEN %s AND %s)
        ORDER BY gdp DESC, inflation;
    """
    
    # This is a read-only query, no transaction needed
    with cn.cursor() as rs:
        rs.execute(q, (min_gdp, max_gdp, min_inf, max_inf))
        rows = rs.fetchall()
        
        if not rows:
            print("\nNo countries found matching the specified criteria.")
            return

        print("\n--- Matching Countries ---")
        for row in rows:
            name, code, gdp, inflation = row
            print(f"{name} ({code}), per capita gdp ${gdp}, inflation rate {inflation}%")


# (Menu 5) Updates a country's gdp and inflation.
def update_country(cn):
    print("\n--- Update Country GDP and Inflation ---")

    code = input("Country code..................: ").upper()
    new_gdp = int(input("Country per capita gdp (USD)..: "))
    new_inf = float(input("Country inflation (pct).......: "))

    with cn.transaction():
        with cn.cursor() as rs:
            # (a) Check if country exists
            q = """
                SELECT country_code FROM Country
                WHERE country_code = %s;
            """
            rs.execute(q, (code,))
            # if this returns true then there is a country with the specified country code
            if rs.fetchone():
            
                q = """
                    UPDATE Country
                    SET gdp = %s, inflation = %s
                    WHERE country_code = %s;
                """
                rs.execute(q, (new_gdp, new_inf, code))
            
            else:
                # (c) Notify user 
                print(f"\nError: Country with code '{code}' does not exist.")


# (Menu 6) Removes a border from the database.
def remove_border(cn):
    print("\n--- Remove Border ---")

    code1 = input("Country code 1..: ").upper()
    code2 = input("Country code 2..: ").upper()
    
    with cn.transaction():
        with cn.cursor() as rs:
            # (a) Check if the border exists (in either direction)
            q = """
                SELECT * FROM Border
                WHERE (country_code_1 = %s AND country_code_2 = %s)
                    OR (country_code_1 = %s AND country_code_2 = %s);
            """
            rs.execute(q, (code1, code2, code2, code1))
            
            # if fetchone() returns a row, the border exists
            if rs.fetchone():
                # (b) Border exists, so remove it
                q = """
                    DELETE FROM Border
                    WHERE (country_code_1 = %s AND country_code_2 = %s)
                        OR (country_code_1 = %s AND country_code_2 = %s);
                """
                rs.execute(q, (code1, code2, code2, code1))
            
            else:
                # (c) Notify user that the border was not found
                print(f"\nError: Border between '{code1}' and '{code2}' does not exist.")


def main():
    # connection info
    hst = config.HOST
    usr = config.USER
    pwd = config.PASSWORD
    dat = config.DATABASE


    # make a connection
    with pg.connect(host=hst, user=usr, password=pwd, dbname=dat) as cn:
        
        
        while True:
            input = show_main_menu()
            
            if input == '1':
                # List countries
                list_countries(cn)
            elif input == '2':
                # Add country
                add_country(cn)
            elif input == '3':
                # Add border
                add_border(cn)
            elif input == '4':
                # Find countries based on gdp and inflation
                find_countries(cn)
            elif input == '5':
                # Update country's gdp and inflation
                update_country(cn)
            elif input == '6':
                # Remove border
                remove_border(cn)
            elif input == '7':
                # Exit
                print("Exiting. Chao!")
                break
            

    
if __name__ == '__main__':
    main()
