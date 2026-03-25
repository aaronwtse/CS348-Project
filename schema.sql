CREATE TABLE IF NOT EXISTS clubs (
    club_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    name         TEXT    NOT NULL,
    city         TEXT    NOT NULL,
    country      TEXT    NOT NULL,
    founded_year INTEGER
);


CREATE TABLE IF NOT EXISTS positions (
    position_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    position_name TEXT NOT NULL
);


CREATE TABLE IF NOT EXISTS players (
    player_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    name          TEXT    NOT NULL,
    age           INTEGER NOT NULL,
    nationality   TEXT    NOT NULL,
    strong_foot   TEXT    NOT NULL CHECK(strong_foot IN ('Left', 'Right', 'Both')),
    jersey_number INTEGER,
    club_id       INTEGER,
    position_id   INTEGER,
    FOREIGN KEY (club_id)     REFERENCES clubs(club_id),
    FOREIGN KEY (position_id) REFERENCES positions(position_id)
);


CREATE TABLE IF NOT EXISTS matches (
    match_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    home_club_id INTEGER NOT NULL,
    away_club_id INTEGER NOT NULL,
    match_date   DATE    NOT NULL,
    venue        TEXT,
    home_score   INTEGER DEFAULT 0,
    away_score   INTEGER DEFAULT 0,
    status       TEXT    NOT NULL DEFAULT 'Scheduled'
                         CHECK(status IN ('Scheduled', 'Completed', 'Postponed')),
    FOREIGN KEY (home_club_id) REFERENCES clubs(club_id),
    FOREIGN KEY (away_club_id) REFERENCES clubs(club_id)
);

-- index
CREATE INDEX IF NOT EXISTS idx_players_club  ON players(club_id);
CREATE INDEX IF NOT EXISTS idx_matches_date  ON matches(match_date);
CREATE INDEX IF NOT EXISTS idx_matches_home  ON matches(home_club_id);
CREATE INDEX IF NOT EXISTS idx_matches_away  ON matches(away_club_id);



INSERT INTO clubs (name, city, country, founded_year) VALUES
    ('Real Madrid',         'Madrid',     'Spain',   1902),
    ('FC Barcelona',        'Barcelona',  'Spain',   1899),
    ('Manchester City',     'Manchester', 'England', 1880),
    ('Bayern Munich',       'Munich',     'Germany', 1900),
    ('Paris Saint-Germain', 'Paris',      'France',  1970);

INSERT INTO positions (position_name) VALUES
    ('Goalkeeper'),
    ('Defender'),
    ('Midfielder'),
    ('Forward');

INSERT INTO players (name, age, nationality, strong_foot, jersey_number, club_id, position_id) VALUES
    ('Vinicius Jr.',         24, 'Brazilian', 'Right', 7,  1, 4),
    ('Luka Modric',          39, 'Croatian',  'Right', 10, 1, 3),
    ('Kylian Mbappe',        26, 'French',    'Right', 9,  1, 4),
    ('Pedri',                22, 'Spanish',   'Right', 8,  2, 3),
    ('Robert Lewandowski',   36, 'Polish',    'Right', 9,  2, 4),
    ('Erling Haaland',       24, 'Norwegian', 'Left',  9,  3, 4),
    ('Kevin De Bruyne',      33, 'Belgian',   'Both', 17, 3, 3),
    ('Harry Kane',           31, 'English',   'Right', 9,  4, 4),
    ('Gianluigi Donnarumma', 26, 'Italian',   'Right', 99, 5, 1);

INSERT INTO matches (home_club_id, away_club_id, match_date, venue, home_score, away_score, status) VALUES
    (1, 2, '2026-01-15', 'Santiago Bernabeu',  2, 1, 'Completed'),
    (3, 4, '2026-01-20', 'Etihad Stadium',     3, 1, 'Completed'),
    (2, 3, '2026-02-05', 'Camp Nou',           1, 1, 'Completed'),
    (4, 5, '2026-02-12', 'Allianz Arena',      2, 0, 'Completed'),
    (5, 1, '2026-03-01', 'Parc des Princes',   1, 3, 'Completed'),
    (1, 3, '2026-04-10', 'Santiago Bernabeu',  0, 0, 'Scheduled'),
    (2, 4, '2026-04-15', 'Camp Nou',           0, 0, 'Scheduled'),
    (3, 5, '2026-05-01', 'Etihad Stadium',     0, 0, 'Scheduled');