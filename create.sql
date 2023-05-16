
--create artist table:
CREATE TABLE
    artist (
        artist_id SERIAL PRIMARY KEY,
        artist_name VARCHAR(50) NOT NULL,
        sex VARCHAR(6) NOT NULL,
        age int NOT NULL CHECK (age >= 18),
        language VARCHAR(50) NOT NULL,
        location VARCHAR(100) NOT NULL
    );
	
	
--create album table:
CREATE TABLE
    album (
        album_name VARCHAR(100) PRIMARY KEY,
        playtime TIME WITH TIME ZONE NOT NULL,
        no_of_tracks INT NOT NULL CHECK (no_of_tracks >= 0),
        year INT NOT NULL,
        artist_id INT,
        FOREIGN KEY (artist_id) REFERENCES artist (artist_id)
    );

	
--create songfile table:
CREATE TABLE
    songfile (
        track_id SERIAL PRIMARY KEY,
        song_title VARCHAR(50) NOT NULL,
        format VARCHAR(50) NOT NULL,
        language VARCHAR(50) NOT NULL,
        year INT NOT NULL,
        location VARCHAR(100) NOT NULL,
        playtime TIME WITH TIME ZONE NOT NULL,
        artist_id INT,
        album_name VARCHAR(100),
        FOREIGN KEY (artist_id) REFERENCES artist (artist_id),
        FOREIGN KEY (album_name) REFERENCES album (album_name)
         
    );

--create genre table:
CREATE TABLE
    genre (
        genre_name VARCHAR(50) PRIMARY KEY,
        year INT NOT NULL,
        description VARCHAR(255) NOT NULL
    );


--create playlist table:
CREATE TABLE
    playlist (
        playlist_id SERIAL PRIMARY KEY,
        playlist_name VARCHAR(50) NOT NULL,
        no_of_tracks INT  CHECK (no_of_tracks >= 0),
        status VARCHAR(20) ,
        playtime TIME WITH TIME ZONE
    );

--create user_table table:
CREATE TABLE
    user_profile (
        user_id SERIAL PRIMARY KEY,
        sex VARCHAR(10) NOT NULL,
		age INT NOT NULL CHECK (age >= 13),
		username VARCHAR(50) NOT NULL UNIQUE,
        password VARCHAR(100) NOT NULL,
        location VARCHAR(50) NOT NULL
    );
    
    
--create musiclabel table:
CREATE TABLE
    musiclabel (
        label_id SERIAL PRIMARY KEY,
        label_name VARCHAR(25) NOT NULL,
        year INT NOT NULL,
        no_of_artist INT NOT NULL CHECK (no_of_artist >= 0)
    );
		
--create playbackdevice table:
CREATE TABLE
    playbackdevice (
        device_id SERIAL PRIMARY KEY,
        user_id INT, 
        type VARCHAR(50) NOT NULL,
        name VARCHAR(50) NOT NULL,
        FOREIGN KEY (user_id) REFERENCES user_profile (user_id)
		ON DELETE CASCADE 
		ON UPDATE NO ACTION
    );
  
--create playhistory table:
CREATE TABLE 
    playhistory (
        playhistory_id INT,
        user_id INT,
        track_id INT,
        playdate TIMESTAMP WITH TIME ZONE NOT NULL,
		device_id INT,
        PRIMARY KEY (user_id, playhistory_id, playdate),
        FOREIGN KEY (user_id) REFERENCES user_profile(user_id) 
	    ON DELETE CASCADE,
        FOREIGN KEY (track_id) REFERENCES songfile(track_id) 
	    ON DELETE CASCADE,
        FOREIGN KEY (device_id) REFERENCES playbackdevice(device_id) 
	    ON DELETE CASCADE
        
);


--create subgenre table:
CREATE TABLE
    subgenre (
        subgenre_id INT,
        genre_name VARCHAR(50), 
        subgenre_name VARCHAR(25) NOT NULL,
        year INT NOT NULL,
        description VARCHAR(255) NOT NULL,
        PRIMARY KEY (subgenre_id, genre_name),
        FOREIGN KEY (genre_name) REFERENCES genre (genre_name)
        ON DELETE CASCADE 
    );



--create subscription table:
CREATE TABLE
    subscription (
        subscription_id SERIAL PRIMARY KEY,
        start_date DATE NOT NULL,
        end_date DATE CHECK (end_date >= start_date),
        sub_name VARCHAR(25) NOT NULL
    );



--create category_of table:
CREATE TABLE
    category_of (
        genre_name VARCHAR(50), 
        track_id INT,
        PRIMARY KEY (genre_name, track_id),
        FOREIGN KEY (genre_name) REFERENCES genre (genre_name)
		ON DELETE CASCADE 
		ON UPDATE NO ACTION,
		FOREIGN KEY (track_id)REFERENCES songfile (track_id) 
		ON DELETE CASCADE 
		ON UPDATE NO ACTION
    );

--create put_in table:
CREATE TABLE
    put_in (
        playlist_id INT,
        track_id INT,
        PRIMARY KEY (playlist_id, track_id),
        FOREIGN KEY (playlist_id) REFERENCES playlist (playlist_id) ON DELETE CASCADE,
        FOREIGN KEY (track_id) REFERENCES songfile (track_id) ON DELETE CASCADE
);


--create subscription table:
CREATE TABLE
    contracted_by (
        artist_id INT , 
        label_id INT ,
        PRIMARY KEY (artist_id, label_id),
        FOREIGN KEY (artist_id) REFERENCES artist (artist_id)
		ON DELETE CASCADE 
		ON UPDATE NO ACTION,
        FOREIGN KEY (label_id)REFERENCES musiclabel (label_id) 
		ON DELETE CASCADE 
		ON UPDATE NO ACTION
    );

--create created_by table:
CREATE TABLE
    created_by (
        playlist_id INT,
        user_id INT, 
        PRIMARY KEY (playlist_id, user_id),
        FOREIGN KEY (playlist_id) REFERENCES playlist (playlist_id)
		ON DELETE CASCADE 
		ON UPDATE NO ACTION,
		FOREIGN KEY (user_id) REFERENCES user_profile (user_id) 
		ON DELETE CASCADE 
		ON UPDATE NO ACTION
    );


--create subscription_type table:
CREATE TABLE
    subscription_type (
        user_id INT , 
        subscription_id INT ,
        price DECIMAL(10, 2) NOT NULL,
        PRIMARY KEY (subscription_id, user_id),
        FOREIGN KEY (user_id) REFERENCES user_profile (user_id)
		ON DELETE CASCADE 
		ON UPDATE NO ACTION,
        FOREIGN KEY (subscription_id) REFERENCES subscription (subscription_id) 
		ON DELETE CASCADE 
		ON UPDATE NO ACTION
    );


--create distributed_by table:
CREATE TABLE
    distributed_by (
        label_id INT , 
        album_name VARCHAR(100) , 
        PRIMARY KEY (label_id, album_name),
        FOREIGN KEY (label_id) REFERENCES musiclabel (label_id)
		ON DELETE CASCADE 
		ON UPDATE NO ACTION,
        FOREIGN KEY (album_name)REFERENCES album (album_name)
		ON DELETE CASCADE 
		ON UPDATE NO ACTION
    );

