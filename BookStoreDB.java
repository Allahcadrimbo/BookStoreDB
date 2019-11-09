/*
 * Authors: Grant Mitchell and Dan Anderson
 */
package bookstoredb;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;
import oracle.jdbc.internal.OracleTypes;
import oracle.jdbc.pool.OracleDataSource;

/**
 *
 * @author Grant Mitchell and Dan Anderson This class is the JDBC implementation
 * for the bookstore
 */
public class BookstoreDB {

    String jdbcUrl = "jdbc:oracle:thin:@akka.d.umn.edu:1521:xe";
    Connection conn;

    /**
     * Main Method
     *
     * @param args the command line arguments
     * @throws java.sql.SQLException
     */
    public static void main(String[] args) throws SQLException {
        String answer;
        //Declare and initialize and object of type BookstoreDB
        BookstoreDB db;
        db = new BookstoreDB();

        //Call the member function to connect to the database in Oracle
        db.getDBConnection();

        do {
            //Prompts the user and reads in their input
            System.out.println("Would you like to perform Query (1 or 2): ");
            Scanner input = new Scanner(System.in);
            int choice = input.nextInt();

            //Verify good input
            if (choice == 1 || choice == 2) {
                //Calls the function to execute the query of choice
                db.queryExecute(choice);
            }

            System.out.println("Would you like to perform another query (Y/N): ");
            answer = input.next();
        } while (answer.toUpperCase().equals("Y"));
    }

    /**
     * This class gets the current DB connection. This is not to be used in
     * production environments. You should use a connection pool instead.
     *
     * @return A connection to the BookstoreDB
     * @throws SQLException
     */
    public Connection getDBConnection() throws SQLException {
        OracleDataSource ds = new OracleDataSource();
        ds.setURL(jdbcUrl);

        if (conn == null) {
            // Prompt for username. Read in users input.    
            System.out.println("Oracle Username: ");
            Scanner input = new Scanner(System.in);
            String username = input.next();

            // Prompt for password. Read in users input. 
            System.out.println("Oracle Password: ");
            String password = input.next();

            conn = ds.getConnection(username, password);
        }
        conn.setAutoCommit(true);

        return conn;
    }

    /*
    * This method executes query 1 or 2. Query 1 outputs the name and email of customers
    * when they have a user specified title in their shopping cart. Query 2 
    * outputs the title of the books that are out of stock in all warehouses.
    *@param choice Which query they want to perform
    *@throws SQLException
     */
    public void queryExecute(int choice) throws SQLException {
        String result, resultEmail, resultName, call, title;
        title = "";
        //Sets call based on query chosen
        if (choice == 1) {
            //Prompts for the book title for query1's parameter and reads in their input
            System.out.println("What title would you like to search for: ");
            Scanner input = new Scanner(System.in);
            title = input.nextLine();
            //Initialize a string to the call of the stored function;
            call = "{? = call findEmailName(?)}";
        } else {
            call = "{? = call findOutOfStock}";
        }

        //Prepare a call to the stored PL/SQL function defined by call
        CallableStatement stmt = conn.prepareCall(call);

        //Setup the output and specify its output type as CURSOR becuase the 
        //SQL function returns a SYS_REFCURSOR
        //This statement is setting the first question mark in the call
        stmt.registerOutParameter(1, OracleTypes.CURSOR);

        //Set the parameter of the function to the title entered by the user
        //This statement is setting the second question mark in the call for query 1
        //This only needs to be done for query 1
        if (choice == 1) {
            stmt.setString(2, title);
        }

        //Executes the statement which then calls the call to the stored function
        stmt.execute();
        //Declare and initialize a ResultSet to the value of the statements output 
        ResultSet rst = (ResultSet) stmt.getObject(1);

        //Output result of query
        if (choice == 1) {
            System.out.println("These people have " + title + " in their cart: ");
        } else {
            System.out.println("These books are out of stock: ");
        }

        //Loops through the ResultSet while there is still another row
        while (rst.next()) {
            //Set two string values to the value of x row in column 1 and 2
            if (choice == 1) {
                resultEmail = rst.getString(1);
                resultName = rst.getString(2);
                System.out.println("Email: " + resultEmail + "    Name: " + resultName + "\n");
            } else {
                //Set one string value to the value of x row in column 1
                result = rst.getString(1);
                System.out.println(result);
            }
        }
    }
}
