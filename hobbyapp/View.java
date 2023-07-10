public class View {
  /**
   * Displays the first welcome message on booting up the program.
   */
  public void welcomeMsg() {
    String startMsg =
            "\n                      *** Welcome to the Hobby Tracker! ***                            \n" +
                    "If you're unsure where to start, call --help for a list of the commands available to you!\n" +
                    "              Otherwise, feel free to jump in and start using our Tracker.               \n" +
                    "                    We hope that you enjoy using the program. :)                         \n";
    System.out.println(startMsg);
  }

  /**
   * Display a help message of all the commands possible.
   */
  public void helpMsg() {
    String helpMsg =
            "\n" +
                    "A number of commands are available to you: \n" +
                    "Usage: --<command> [arguments]\n" +
                    "--help                                                           Displays this message!\n" +
                    "--listHobbies                                                    Lists all available hobbies, and their information.\n" +
                    "--listHobbyCommands                                              Lists more specific info on how to add hobbies.\n" +
                    "--listHobbiesOf <Username>                                       Lists this user's hobbies.\n" +
                    "--addUser <Username> <Date of Birth>                             Add a user to the Database.\n" +
                    "--addHobby <Username> <Hobby> [field1, ...]                      Add a hobby to the Database, performed by a given user.\n" +
                    "--updateHobby <Username> <Hobby> [field1, ...]                   Update a stored hobby with a new value.\n" +
                    "--removeHobby <Username> <Hobby> <Instance_to_remove>            Removes the given hobby.\n" +
                    "--exit                                                           Exits the program.\n";
    System.out.println(helpMsg);
  }

  /**
   * Display a more detailed version of each of the commands.
   */
  public void listHobbyCommands() {
    String helpMsg =
            "\n" +
                    "--addUser <Username> <DateOfBirth>\n" +
                    "--addHobby <Username> Sport <NameOfSport> <PlayerCount> <Outdoors?> <CostToBegin> <Season> <TeamSport?>\n" +
                    "--addHobby <Username> Video_Game <NameOfGame> <Genre> <Multiplayer?> <Mobile?> <Computer?> <Console?>\n" +
                    "--addHobby <Username> Board_Game <NameOfGame> <Genre> <NumberOfPlayers> <Duration>\n" +
                    "Two options for collectible cards: \n" +
                    "   --addHobby <Username> Collectible_Card <Valuable?> <YearOfPrint> <isBaseball?> FALSE <Name> <Position> <YearOfPlay> <Team> <FunFact>\n" +
                    "   --addHobby <Username> Collectible_Card <Valuable?> <YearOfPrint> FALSE <isPokemon?> <PokemonName> <PokemonType>\n" +
                    "--updateHobby <Username> <HobbyType> [field1, ..., field n]\n" +
                    "--removeHobby <Username> <HobbyType> <Primary_Key_of_Instance>\n";
    System.out.println(helpMsg);
  }

  /**
   * List all the possible hobbies.
   */
  public void listHobbies() {
    String hobbyList =
            "\nHobbies to choose from: \n" +
                    "* Sport: \n" +
                    "   Information it stores...\n" +
                    "     Name of sport,\n" +
                    "     Player Count, \n" +
                    "     Is it played outdoors,\n" +
                    "     Cost to begin,\n" +
                    "     The season it's played in,\n" +
                    "     Whether it's a team sport\n" +
                    "* Video_Game: \n" +
                    "   Information it stores...\n" +
                    "     Name of game,\n" +
                    "     Genre of game, \n" +
                    "     Is it multiplayer,\n" +
                    "     Is it mobile,\n" +
                    "     Is it computer based,\n" +
                    "     Is it console based\n" +
                    "* Board_Game: \n" +
                    "   Information it stores...\n" +
                    "     Name of game,\n" +
                    "     Genre of game, \n" +
                    "     The player count,\n" +
                    "     The time duration\n" +
                    "* Book: \n" +
                    "   Information it stores...\n" +
                    "     Title,\n" +
                    "     Author, \n" +
                    "     Genre,\n" +
                    "     Year of Publication\n" +
                    "* Collectible_Card: \n" +
                    "   Information it stores...\n" +
                    "     Whether it's valuable,\n" +
                    "     The year of print, \n" +
                    "     Whether it's a baseball card,\n" +
                    "     Whether it's a pokemon card,\n" +
                    "         If baseball, it also stores...\n" +
                    "         Player name,\n" +
                    "         Position,\n" +
                    "         Year of play,\n" +
                    "         The team played on,\n" +
                    "         A fun fact (use underscores for spaces)\n" +
                    "     Whether it's a pokemon card\n"+
                    "         If pokemon, it also stores...\n" +
                    "         Pokemon name,\n" +
                    "         Pokemon type\n";
    System.out.println(hobbyList);
  }
}
