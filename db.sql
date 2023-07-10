 CREATE DATABASE IF NOT EXISTS dbtoralsmayerd;
 use dbtoralsmayerd;
  


 CREATE TABLE IF NOT EXISTS person (
    username VARCHAR(32) PRIMARY KEY,
    date_of_birth DATE NOT NULL CONSTRAINT CHECK (date_of_birth > '1900-01-01'),
    num_hobbies INT DEFAULT 0
 );
 
 
 CREATE TABLE IF NOT EXISTS sport (
	name VARCHAR(32) PRIMARY KEY,
    player_count INT DEFAULT 1,
    outdoors BOOLEAN,
    cost_to_begin INT DEFAULT 0,
    season VARCHAR(32) DEFAULT "Unknown",
    team_sport BOOLEAN
);

-- renamed from "participates in"
-- relation table:  Person -- (Plays) --> Sport
CREATE TABLE IF NOT EXISTS plays_sport (
	id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(32) NOT NULL,
    sport_name VARCHAR(32) NOT NULL,
	CONSTRAINT sport_person_fk
		FOREIGN KEY (username)
		REFERENCES person (username)
        ON UPDATE CASCADE ON DELETE RESTRICT,
	CONSTRAINT sport_fk
		FOREIGN KEY (sport_name)
		REFERENCES sport (name)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS video_game (
	name VARCHAR(64) PRIMARY KEY,
    genre VARCHAR(64) DEFAULT "Unknown",
    multiplayer BOOL,
    mobile BOOL,
    computer BOOL,
    console BOOL
);


-- relation table:  Person -- (Plays) --> Video Game
CREATE TABLE IF NOT EXISTS plays_game (
	id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(32) NOT NULL,
    game_name VARCHAR(32) NOT NULL,
	CONSTRAINT game_person_fk
		FOREIGN KEY (username)
		REFERENCES person (username)
        ON UPDATE CASCADE ON DELETE RESTRICT,
	CONSTRAINT game_fk
		FOREIGN KEY (game_name)
		REFERENCES video_game (name)
        ON UPDATE CASCADE ON DELETE RESTRICT
);


CREATE TABLE IF NOT EXISTS board_game (
	name VARCHAR(64) PRIMARY KEY,
    genre VARCHAR(32) DEFAULT "Unknown",
    player_count INT DEFAULT 1,
    duration INT
);

-- relation table:  Person -- (Owns BoardGame) --> Board Game 
CREATE TABLE IF NOT EXISTS owns_bg (
	id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(32) NOT NULL,
    game_name VARCHAR(64) NOT NULL,
	CONSTRAINT brdgame_person_fk
		FOREIGN KEY (username)
		REFERENCES person (username)
        ON UPDATE CASCADE ON DELETE RESTRICT,
	CONSTRAINT brdgame_fk
		FOREIGN KEY (game_name)
		REFERENCES board_game (name)
        ON UPDATE CASCADE ON DELETE RESTRICT
);


CREATE TABLE IF NOT EXISTS book (
	title VARCHAR(64) PRIMARY KEY,
    author VARCHAR(64) NOT NULL DEFAULT "Unknown",
    genre VARCHAR(64) DEFAULT "Unknown",
    year_of_publication INT NOT NULL
);

-- relation table:  Person -- (Owns Book) --> Book 
CREATE TABLE IF NOT EXISTS owns_book (
	id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(32) NOT NULL,
    book_name VARCHAR(64) NOT NULL,
	CONSTRAINT book_person_fk
		FOREIGN KEY (username)
		REFERENCES person (username)
        ON UPDATE CASCADE ON DELETE RESTRICT,
	CONSTRAINT book_fk
		FOREIGN KEY (book_name)
		REFERENCES book (title)
        ON UPDATE CASCADE ON DELETE RESTRICT
);


CREATE TABLE IF NOT EXISTS collectible_card (
	card_num INT PRIMARY KEY AUTO_INCREMENT, 
    valuable BOOL,
    year_of_print INT,
    isBaseball BOOL,
    isPokemon BOOL, 
    CONSTRAINT CHECK (isBaseball = TRUE || isPokemon = TRUE)
    -- needs to be one or other
);

CREATE TABLE IF NOT EXISTS baseball_card (
	player_name VARCHAR(64) PRIMARY KEY,
    corresponding_card INT NOT NULL,
    position VARCHAR(64), 
    year_of_play INT CONSTRAINT CHECK (year_of_play > 1839),
    team VARCHAR(64),
    fun_fact VARCHAR(256),
	CONSTRAINT baseball_fk_collectible FOREIGN KEY (corresponding_card)
		REFERENCES collectible_card (card_num)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS pokemon_card (
	pokemon_name VARCHAR(64) PRIMARY KEY,
    corresponding_card INT NOT NULL,
    CONSTRAINT pokemon_fk_collectible FOREIGN KEY (corresponding_card)
		REFERENCES collectible_card (card_num)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- Need to prompt user to input pokemon types, then correspondingly create 
-- enough pokemon type tables to represent this
CREATE TABLE IF NOT EXISTS pokemon_type (
	auto_id INT PRIMARY KEY AUTO_INCREMENT,
    pokemon_name VARCHAR(64) NOT NULL,
    element_type ENUM('Normal', 'Fire', 'Water', 'Grass', 'Electric', 'Ice', 'Fighting', 
					  'Poison', 'Ground', 'Flying', 'Psychic', 'Bug', 'Rock', 'Ghost', 'Dark', 
					  'Dragon', 'Steel', 'Fairy'),
	CONSTRAINT pokemon_fk_type FOREIGN KEY (pokemon_name)
		REFERENCES pokemon_card (pokemon_name)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

DROP TABLE IF EXISTS person_collected_card;
CREATE TABLE IF NOT EXISTS person_collected_card (
	id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(32) NOT NULL,
    card_num INT NOT NULL,
    CONSTRAINT card_person_fk FOREIGN KEY (username)
		REFERENCES person (username)
        ON UPDATE CASCADE ON DELETE RESTRICT,
	CONSTRAINT collected_card_fk FOREIGN KEY (card_num)
		REFERENCES collectible_card (card_num)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ------------------  Triggers to update Hobby Count in person  ----------------------------------------------

DROP TRIGGER IF EXISTS update_count_from_sport;
DELIMITER $$
CREATE TRIGGER update_count_from_sport BEFORE INSERT ON plays_sport 
FOR EACH ROW
BEGIN
	UPDATE person SET num_hobbies = num_hobbies + 1 WHERE person.username = new.username;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS update_count_from_vg;
DELIMITER $$
CREATE TRIGGER update_count_from_vg BEFORE INSERT ON plays_game 
FOR EACH ROW
BEGIN
	UPDATE person SET num_hobbies = num_hobbies + 1 WHERE person.username = new.username;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS update_count_from_bg;
DELIMITER $$
CREATE TRIGGER update_count_from_bg BEFORE INSERT ON owns_bg 
FOR EACH ROW
BEGIN
	UPDATE person SET num_hobbies = num_hobbies + 1 WHERE person.username = new.username;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS update_count_from_book;
DELIMITER $$
CREATE TRIGGER update_count_from_book BEFORE INSERT ON owns_book 
FOR EACH ROW
BEGIN
	UPDATE person SET num_hobbies = num_hobbies + 1 WHERE person.username = new.username;
END$$
DELIMITER ;

DROP TRIGGER IF EXISTS update_count_from_card;
DELIMITER $$
CREATE TRIGGER update_count_from_card BEFORE INSERT ON person_collected_card 
FOR EACH ROW
BEGIN
	UPDATE person SET num_hobbies = num_hobbies + 1 WHERE person.username = new.username;
END$$
DELIMITER ;
-- ---------------------------- Create commands for distinct Hobbies -------------------------------------------------

DROP PROCEDURE IF EXISTS create_sport;
DELIMITER $$
CREATE PROCEDURE create_sport(username_p VARCHAR(32), sportname_p VARCHAR(32), playerct_p INT, outdoors_p BOOL, cost_p INT, season_p VARCHAR(32), teamsport_p BOOL)
BEGIN
INSERT INTO sport VALUES (sportname_p, playerct_p, outdoors_p, cost_p, season_p, teamsport_p) 
	on duplicate key update player_count = playerct_p, outdoors = outdoors_p, cost_to_begin = cost_p, 
							season = season_p, team_sport = teamsport_p;

	IF NOT EXISTS (SELECT username, sport_name FROM plays_sport 
				WHERE username = username_p AND sport_name = sportname_p)
			THEN
            INSERT INTO plays_sport (username, sport_name) VALUES (username_p, sportname_p) on duplicate key update username = username_p;
	END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS create_vg;
DELIMITER $$
CREATE PROCEDURE create_vg(username_p VARCHAR(32), name_p VARCHAR(32), genre_p VARCHAR(64), multiplayer_p BOOL, mobile_p BOOL, computer_p BOOL, console_p BOOL)
BEGIN

INSERT INTO video_game VALUES (name_p, genre_p, multiplayer_p, mobile_p, computer_p, console_p) on duplicate key update name = name_p;
INSERT INTO plays_game (username, game_name) VALUES (username_p, name_p) on duplicate key update username = username_p;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS create_bg;
DELIMITER $$
CREATE PROCEDURE create_bg(username_p VARCHAR(32), name_p VARCHAR(32), genre_p VARCHAR(64), playercount_p INT, duration_p INT)
BEGIN
INSERT INTO board_game VALUES (name_p, genre_p, playercount_p, duration_p) on duplicate key update name = name_p;
INSERT INTO owns_bg (username, game_name) VALUES (username_p, name_p) on duplicate key update username = username_p;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS create_book;
DELIMITER $$
CREATE PROCEDURE create_book(username_p VARCHAR(32), title_p VARCHAR(64), author_p VARCHAR(64), genre_p VARCHAR(64), yop_p INT)
BEGIN
	INSERT into book VALUES (title_p, author_p, genre_p, yop_p) ON DUPLICATE KEY UPDATE author = author_p, genre = genre_p, year_of_publication = yop_p; 
    
	IF NOT EXISTS (SELECT username, book_name FROM owns_book 
		WHERE username = username_p AND book_name = title_p)
        THEN INSERT INTO owns_book (username, book_name) VALUES (username_p, title_p);
	END IF;
    
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS create_baseball_card;
DELIMITER $$
CREATE PROCEDURE create_baseball_card(username_p VARCHAR(32), valuable_p BOOL, yop_p INT, player_name_p VARCHAR(64), position_p VARCHAR(64), year_playing_p INT, team_p VARCHAR(64), funfact_p VARCHAR(256))
BEGIN
INSERT INTO collectible_card (valuable, year_of_print, isBaseball) VALUES (valuable_p, yop_p, TRUE) AS t1 on duplicate key update valuable = valuable_p;
INSERT INTO baseball_card VALUES (player_name_p,  (SELECT MAX(card_num) from collectible_card
                                                    WHERE valuable = valuable_p
                                                    AND year_of_print = yop_p
                                                    AND isBaseball = TRUE), position_p, year_playing_p, team_p, funfact_p) on duplicate key update player_name = player_name_p;
INSERT INTO person_collected_card (username, card_num) VALUES (username_p,  (SELECT MAX(card_num) from collectible_card
                                                    WHERE valuable = valuable_p
                                                    AND year_of_print = yop_p
                                                    AND isBaseball = TRUE)) on duplicate key update username = username_p;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS create_pokemon_card;
DELIMITER $$
CREATE PROCEDURE create_pokemon_card(username_p VARCHAR(32), valuable_p BOOL, yop_p INT, pokemon_name_p VARCHAR(64), type_p ENUM('Normal', 'Fire', 'Water', 'Grass', 'Electric', 'Ice', 'Fighting', 
					  'Poison', 'Ground', 'Flying', 'Psychic', 'Bug', 'Rock', 'Ghost', 'Dark', 
					  'Dragon', 'Steel', 'Fairy'))
BEGIN

INSERT INTO collectible_card (valuable, year_of_print, isBaseball, isPokemon) VALUES (valuable_p, yop_p, FALSE, TRUE) AS t1;
INSERT INTO pokemon_card VALUES (pokemon_name_p,  (SELECT MAX(card_num) from collectible_card
                                                    WHERE valuable = valuable_p
                                                    AND year_of_print = yop_p
                                                    AND isBaseball = FALSE)) on duplicate key update pokemon_name = pokemon_name_p;
INSERT INTO pokemon_type (pokemon_name, element_type) VALUES (pokemon_name_p, type_p) on duplicate key update pokemon_name = pokemon_name_p;
INSERT INTO person_collected_card (username, card_num) VALUES (username_p,  (SELECT MAX(card_num) from collectible_card
                                                    WHERE valuable = valuable_p
                                                    AND year_of_print = yop_p
                                                    AND isBaseball = FALSE)) on duplicate key update username = username_p;
END$$
DELIMITER ;

-- ---------------------------- Getter commands for user's Hobbies -------------------------------------------------


DROP PROCEDURE IF EXISTS get_user_sports;
DELIMITER $$
CREATE PROCEDURE get_user_sports(username_p VARCHAR(32))
BEGIN
SELECT * FROM sport 
    WHERE sport.name IN 
        (SELECT sport_name FROM plays_sport WHERE plays_sport.username = username_p);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS get_user_video_games;
DELIMITER $$
CREATE PROCEDURE get_user_video_games(username_p VARCHAR(32))
BEGIN
SELECT * FROM video_game
    WHERE video_game.name IN 
        (SELECT game_name FROM plays_game WHERE plays_game.username = username_p);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS get_user_board_games;
DELIMITER $$
CREATE PROCEDURE get_user_board_games(username_p VARCHAR(32))
BEGIN
SELECT * FROM board_game 
    WHERE board_game.name IN 
        (SELECT game_name FROM owns_bg WHERE owns_bg.username = username_p);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS get_user_books;
DELIMITER $$
CREATE PROCEDURE get_user_books(username_p VARCHAR(32))
BEGIN
SELECT * FROM book 
    WHERE book.title IN 
        (SELECT book_name FROM owns_book WHERE owns_book.username = username_p);
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS get_user_baseball_cards;
DELIMITER $$
CREATE PROCEDURE get_user_baseball_cards(username_p VARCHAR(32))
BEGIN
SELECT card_num, valuable, year_of_print, isBaseball, player_name, position, year_of_play, team, fun_fact
	FROM collectible_card JOIN baseball_card WHERE card_num = corresponding_card AND 
		 card_num IN (SELECT card_num FROM person_collected_card WHERE username = username_p);
						  
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS get_user_pokemon_cards;
DELIMITER $$
CREATE PROCEDURE get_user_pokemon_cards(username_p VARCHAR(32))
BEGIN
SELECT card_num, valuable, year_of_print, isPokemon, pokemon_card.pokemon_name, element_type
	FROM collectible_card JOIN pokemon_card ON card_num = corresponding_card 
						  JOIN pokemon_type ON pokemon_card.pokemon_name = pokemon_type.pokemon_name
                          WHERE card_num IN (SELECT card_num FROM person_collected_card WHERE username = username_p);
END$$
DELIMITER ;

-- ---------------------------- Removal commands for user's Hobbies -------------------------------------------------


DROP PROCEDURE IF EXISTS remove_sport;
DELIMITER $$
CREATE PROCEDURE remove_sport(username_p VARCHAR(32), sport_name_p VARCHAR(32))
BEGIN
DELETE FROM plays_sport WHERE username = username_p AND sport_name = sport_name_p;
DELETE FROM sport WHERE name = sport_name_p AND (SELECT COUNT(id) FROM plays_sport WHERE sport_name = sport_name_p) = 0;
UPDATE person SET num_hobbies = num_hobbies - 1 WHERE person.username = username_p;
-- Delete from sport table where it's the matching name, and no one plays it.
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS remove_video_game;
DELIMITER $$
CREATE PROCEDURE remove_video_game(username_p VARCHAR(32), video_game_name_p VARCHAR(32))
BEGIN
DELETE FROM plays_game WHERE username = username_p AND game_name = video_game_name_p;
DELETE FROM video_game WHERE name = video_game_name_p AND (SELECT COUNT(id) FROM plays_game WHERE game_name = video_game_name_p) = 0;
UPDATE person SET num_hobbies = num_hobbies - 1 WHERE person.username = username_p;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS remove_board_game;
DELIMITER $$
CREATE PROCEDURE remove_board_game(username_p VARCHAR(32), board_game_name_p VARCHAR(32))
BEGIN
DELETE FROM owns_bg WHERE username = username_p AND game_name = board_game_name_p;
DELETE FROM board_game WHERE name = board_game_name_p AND (SELECT COUNT(id) FROM owns_bg WHERE game_name = board_game_name_p) = 0;
UPDATE person SET num_hobbies = num_hobbies - 1 WHERE person.username = username_p;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS remove_book;
DELIMITER $$
CREATE PROCEDURE remove_book(username_p VARCHAR(32), title_p VARCHAR(32))
BEGIN
DELETE FROM owns_book WHERE username = username_p AND book_name = title_p;
DELETE FROM book WHERE title = title_p AND (SELECT COUNT(id) FROM owns_book WHERE book_name = title_p) = 0;
UPDATE person SET num_hobbies = num_hobbies - 1 WHERE person.username = username_p;
END$$
DELIMITER ;


DROP PROCEDURE IF EXISTS remove_collectible_card;
DELIMITER $$
CREATE PROCEDURE remove_collectible_card(username_p VARCHAR(32), card_num_p VARCHAR(32))
BEGIN
DELETE FROM person_collected_card WHERE username = username_p AND card_num = card_num_p;

	IF (SELECT isBaseball FROM collectible_card WHERE card_num = card_num_p) 
		THEN DELETE FROM baseball_card WHERE corresponding_card = card_num_p;
    ELSE
		DELETE FROM pokemon_card WHERE corresponding_card = card_num_p;
	END IF;

DELETE FROM collectible_card WHERE card_num = card_num_p AND (SELECT COUNT(corresponding_card) FROM person_colleted_card WHERE card_num = card_num_p) = 0;
UPDATE person SET num_hobbies = num_hobbies - 1 WHERE person.username = username_p;
END$$
DELIMITER ;

SELECT * FROM person;

