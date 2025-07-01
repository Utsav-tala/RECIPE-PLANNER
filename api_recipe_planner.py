import pg8000

hostname = 'localhost' 
database = 'recipe'
username = 'postgres'
password = 'postgres'
port_id = 5432

conn = None

try:
    conn = pg8000.connect(
        host=hostname,
        database=database,  # Change from dbname to database
        user=username,
        password=password,
        port=port_id
    )
    print("Connection to PostgreSQL established successfully!")

    # Create a cursor object
    cur = conn.cursor()

    # Execute a sample query
    query = "SELECT r.recipe_id, r.name AS recipe_name,SUM(i.energy) AS total_energy FROM rp.recipe r JOIN rp.rp_ingre ri ON r.recipe_id = ri.recipe_id JOIN rp.ingredient i ON ri.ingre_id = i.ingre_id GROUP BY r.recipe_id, r.name HAVING SUM(i.energy) > ( SELECT AVG(total_energy) FROM ( SELECT SUM(i.energy) AS total_energy FROM rp.recipe r JOIN rp.rp_ingre ri ON r.recipe_id = ri.recipe_id JOIN rp.ingredient i ON ri.ingre_id = i.ingre_id GROUP BY r.recipe_id) AS recipe_energy);"
    cur.execute(query)

    # Fetch and print results
    results = cur.fetchall()
    col_names = [desc[0] for desc in cur.description]
    print("\t".join(col_names))

    for row in results:
        print("\t".join(map(str, row)))

    cur.close()

except pg8000.Error as e:
    print("Error: Could not make connection to the PostgreSQL database")
    print(e)

finally:
    if conn is not None:
        conn.close()
        print("PostgreSQL connection is closed.")