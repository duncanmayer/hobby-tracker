/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.

db.mysql.url="jdbc:mysql://localhost:3306/db?characterEncoding=UTF-8&useSSL=false"
*/

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Properties;
import java.util.Scanner;

/**
 * @author Duncan Mayer and Skye Toral
 */
public class HobbyTracking {

  /**
   * The name of the MySQL account to use (or empty for anonymous)
   */
  private String userName = "";

  /**
   * The password for the MySQL account (or empty for anonymous)
   */
  private String password = "";


  /**
   * Get a new database connection
   *
   * @return The Connection Object
   * @throws SQLException if getConnection fails.
   */
  public Connection getConnection() throws SQLException {
    Connection conn;
    Properties connectionProps = new Properties();
    connectionProps.put("user", this.userName);
    connectionProps.put("password", this.password);

    String dbName = "dbtoralsmayerd";
    int portNumber = 3306;
    String serverName = "localhost";

    conn = DriverManager.getConnection("jdbc:mysql://"
            + serverName + ":" + portNumber + "/" + dbName +
            "?characterEncoding=UTF-8&useSSL=false", connectionProps);

    return conn;
  }

  /**
   * Use a scanner to get user's username and password
   */
  private void getUserAndPass() {
    Scanner sc = new Scanner(System.in);
    System.out.println("Enter your username: ");
    this.userName = sc.nextLine();
    System.out.println("Enter your password: ");
    this.password = sc.nextLine();

    // check and see if a connection could be built using these credentials
    try {
      this.getConnection();
    } catch (SQLException e) {
      e.printStackTrace();
      System.out.println("Wrong credentials!  Please input again.");
      this.getUserAndPass();
    }
  }

  /**
   * Connect to MySQL and do some stuff.
   */
  public void run() {
    View view = new View();
    Connection conn;

    this.getUserAndPass();

    // Connect to MySQL
    try {
      conn = this.getConnection();
      System.out.println("Connected to database");
    } catch (SQLException e) {
      System.out.println("ERROR: Could not connect to the database");
      return;
    }

    view.welcomeMsg();

    Scanner sc = new Scanner(System.in);

    while (true) {
      // split input into args style String array
      String[] args = sc.nextLine().split(" ");

      // exit condition
      if(args[0].equals("--exit")) {
        System.out.println("Exiting from the program.");
        break;
      }
      try {
        parseInput(args, conn);
      } catch (IndexOutOfBoundsException e) {
        System.out.println("Not enough arguments.");
      }
    }

    try {
      conn.close();
    } catch (SQLException e) {
      System.out.println("Closing the connection fails.");
      e.printStackTrace();
    }
  }

  /**
   * Parse the command line inputs by the user.
   * @param args Series of words input by the user
   * @param conn The Connection object
   * @throws IndexOutOfBoundsException if users input an incorrect number of inputs.
   */
  private void parseInput(String[] args, Connection conn) throws IndexOutOfBoundsException {
    View view = new View();
    switch(args[0]) {
      case("--help"):
        view.helpMsg();
        break;
      case("--listHobbies"):
        view.listHobbies();
        break;
      case("--listHobbyCommands"):
        view.listHobbyCommands();
        break;
      case("--listHobbiesOf"):
        System.out.println();
        listHobbiesOf(args[1], conn);
        System.out.println();
        break;
      case("--addUser"):
        addUser(args[1], args[2], conn);
        break;
      case("--addHobby"):
        // give a user the hobby specified
        addHobby(args, conn);
        break;
      case("--updateHobby"):
        // update the hobby specified
        updateHobby(args, conn);
        break;
      case("--removeHobby"):
        removeHobby(args[1], args[2], args[3], conn);
        break;
      default:
        System.out.println("Unknown command.");
        break;
    }
  }

  /**
   * Remove the specified hobby from a user's list of hobbies.  Chosen via primary key.
   * @param username The user being removed from
   * @param hobbyType The type of hobby being pulled from
   * @param primaryKey The unique identifier of the hobby being removed
   * @param conn The connection object
   */
  private void removeHobby(String username, String hobbyType, String primaryKey, Connection conn) {
    String removeCall = String.format("Call remove_%s('%s', '%s')", hobbyType, username, primaryKey);
    CallableStatement stmt;
    try {
      stmt = conn.prepareCall(removeCall);
    if (stmt == null) {
      throw new IllegalArgumentException("stmt cannot be null");
    }
    stmt.execute(removeCall);
    System.out.printf("Removed %s from %s's Hobby List.\n", primaryKey, username);

    } catch (SQLException e) {
      System.out.printf("Failed to execute removal of %s from %s.\n", primaryKey, hobbyType);
    }
  }

  /**
   * Get all the hobbies of a given user
   * @param user The username fetching from
   * @param conn The connection object
   */
  private void listHobbiesOf(String user, Connection conn) {
    try {
      printTable("sports", user, conn);
      printTable("video_games", user, conn);
      printTable("board_games", user, conn);
      printTable("books", user, conn);
      printTable("baseball_cards", user, conn);
      printTable("pokemon_cards", user, conn);
    } catch (SQLException e) {
      System.out.printf("Failed to fetch hobbies of %s.%n", user);
    }
  }

  /**
   * Print the contents of a table for a given user.
   * @param tableName The name of the table
   * @param user The username
   * @param conn The Connection object
   * @throws SQLException if fetching data from the DB fails, or if the query execution fails.
   */
  private void printTable(String tableName, String user, Connection conn) throws SQLException {
    String getTable = String.format("Call get_user_%s('%s')", tableName, user);
    CallableStatement stmt = conn.prepareCall(getTable);
    ResultSet result = stmt.executeQuery();

    while(result.next()) {
      ArrayList<String> row = new ArrayList<>();
      for (int i = 1; i < result.getMetaData().getColumnCount() + 1; i++) {
        row.add(result.getMetaData().getColumnName(i) + ": " + result.getString(i));
      }
      System.out.println(result.getMetaData().getTableName(1) + ": " + row);
    }
  }

  /**
   * Update the hobby specified by user arguments.
   * @param args The user's inputs
   * @param conn The Connection object
   */
  private void updateHobby(String[] args, Connection conn) {
    try {

      PreparedStatement stmt = null;

      if (!args[2].equals("Collectible-Card")) {
        stmt = conn.prepareCall(String.format("SELECT '%s' FROM %s", args[3], args[2]));
        System.out.printf("SELECT '%s' FROM %s%n", args[3], args[2]);
      }

      // This execution will enter the catch block if unable to select the tuple.
      // This means that the tuple does not exist, and cannot be 'updated'.
      if (stmt != null) {
        stmt.execute();
      } else {
        throw new IllegalStateException("Stmt should not be null.");
      }

      addHobby(args, conn);

    } catch (SQLException e) {
      System.out.println("The value you're trying to update does not exist!");
    }
  }

  /**
   * Adds a hobby based on user input.
   * @param args The arguments passed in by the user
   * @param conn The Connection object.
   */
  private void addHobby(String[] args, Connection conn) {
    String s = "";
    switch(args[2]) {
      case("sport"):
      case("Sport"):
        s = String.format("CALL create_sport('%s', '%s', %s, %s, %s, '%s', %s)", args[1], args[3], args[4], args[5], args[6], args[7], args[8]);
        break;
      case("video_game"):
      case("Video_Game"):
        s = String.format("CALL create_vg('%s', '%s', '%s', %s, %s, %s, %s)", args[1], args[3], args[4], args[5], args[6], args[7], args[8]);
        break;
      case("board_game"):
      case("Board_Game"):
        s = String.format("CALL create_bg('%s', '%s', '%s', %s, %s)", args[1], args[3], args[4], args[5], args[6]);
        break;
      case("book"):
      case("Book"):
        s = String.format("CALL create_book('%s', '%s', '%s', '%s', %s)", args[1], args[3], args[4], args[5], args[6]);
        break;
      case("collectible_card"):
      case("Collectible_Card"):
        if (args[5].equalsIgnoreCase("true") && args[6].equalsIgnoreCase("true")) {
          throw new IllegalArgumentException("Cannot be Pokemon and Baseball card.");
        }
        else if (args[5].equalsIgnoreCase("true")) {
          s = String.format("CALL create_baseball_card('%s', %s, %s, '%s', '%s', %s, '%s', '%s')", args[1], args[3], args[4], args[7], args[8], args[9], args[10], args[11]);
        } else if (args[6].equalsIgnoreCase("true")) {
          s = String.format("CALL create_pokemon_card('%s', %s, %s, '%s', '%s')", args[1], args[3], args[4], args[7], args[8]);
        }
        break;
      default:
        System.out.print("\n");
        System.out.println("Invalid hobby addition!\n");
        return;
    }

    try {
      CallableStatement stmt = conn.prepareCall(s);
      stmt.executeQuery();
      System.out.println("Query Executed!");
    } catch (SQLException e) {
       e.printStackTrace();
    }
  }

  /**
   * Inserts into the person table the entry info specified by the user.
   * @param arg The username to insert.
   * @param arg1 The date of birth of the entry.
   * @param conn THe connection object.
   */
  private void addUser(String arg, String arg1, Connection conn) {
    String insert = "INSERT INTO person (username, date_of_birth) VALUES ('" + arg + "', '" + arg1 + "')";
    try {
      PreparedStatement stmt = conn.prepareCall(insert);
      stmt.execute();
    } catch (SQLException e) {
      System.out.println("Duplicate Username!");
    }
  }

  /**
   * Connect to the DB and do some stuff
   *
   * @param args Arguments passed in via Command Line
   */
  public static void main(String[] args) {
    HobbyTracking app = new HobbyTracking();
    app.run();
  }
}
