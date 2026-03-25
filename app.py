import sqlite3
from flask import Flask, render_template, request, redirect, url_for, g

app = Flask(__name__)

#CONNECTION

#gives connection to soccer.db
def get_db():
    if 'db' not in g:
        g.db = sqlite3.connect('soccer.db')
        g.db.row_factory = sqlite3.Row
        g.db.execute('PRAGMA foreign_keys = ON')
    return g.db

@app.teardown_appcontext
def close_db(error):
    db = g.pop('db', None)
    if db is not None:
        db.close()


#ROUTES

@app.route('/')
def index():
    return render_template('index.html')


@app.route('/players')
def players():
    db = get_db()
    all_players = db.execute('''
        SELECT p.player_id, p.name, p.age, p.nationality,
               p.strong_foot, p.jersey_number,
               c.name AS club_name,
               pos.position_name
        FROM players p
        LEFT JOIN clubs c ON p.club_id = c.club_id
        LEFT JOIN positions pos ON p.position_id = pos.position_id
        ORDER BY p.name
    ''').fetchall()
    return render_template('players.html', players=all_players)


@app.route('/players/add', methods=['GET', 'POST'])
def add_player():
    db = get_db()
    clubs = db.execute('SELECT * FROM clubs ORDER BY name').fetchall()
    positions = db.execute('SELECT * FROM positions ORDER BY position_name').fetchall()

    if request.method == 'POST':
        db.execute('''
            INSERT INTO players (name, age, nationality, strong_foot, jersey_number, club_id, position_id)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            request.form['name'],
            request.form['age'],
            request.form['nationality'],
            request.form['strong_foot'],
            request.form['jersey_number'] or None,
            request.form['club_id'] or None,
            request.form['position_id'] or None
        ))
        db.commit()
        return redirect(url_for('players'))

    return render_template('player_form.html', player=None, clubs=clubs, positions=positions)


@app.route('/players/edit/<int:player_id>', methods=['GET', 'POST'])
def edit_player(player_id):
    db = get_db()
    player = db.execute('SELECT * FROM players WHERE player_id = ?', (player_id,)).fetchone()
    clubs = db.execute('SELECT * FROM clubs ORDER BY name').fetchall()
    positions = db.execute('SELECT * FROM positions ORDER BY position_name').fetchall()

    if request.method == 'POST':
        db.execute('''
            UPDATE players
            SET name=?, age=?, nationality=?, strong_foot=?, jersey_number=?, club_id=?, position_id=?
            WHERE player_id=?
        ''', (
            request.form['name'],
            request.form['age'],
            request.form['nationality'],
            request.form['strong_foot'],
            request.form['jersey_number'] or None,
            request.form['club_id'] or None,
            request.form['position_id'] or None,
            player_id
        ))
        db.commit()
        return redirect(url_for('players'))

    return render_template('player_form.html', player=player, clubs=clubs, positions=positions)


@app.route('/players/delete/<int:player_id>', methods=['POST'])
def delete_player(player_id):
    db = get_db()
    db.execute('DELETE FROM players WHERE player_id = ?', (player_id,))
    db.commit()
    return redirect(url_for('players'))


@app.route('/report')
def report():
    db = get_db()
    clubs = db.execute('SELECT * FROM clubs ORDER BY name').fetchall()
    matches = []

    if request.args.get('club_id'):
        club_id = request.args.get('club_id')
        date_from = request.args.get('date_from', '2000-01-01')
        date_to = request.args.get('date_to', '2099-12-31')

        matches = db.execute('''
            SELECT m.*,
                   h.name AS home_name,
                   a.name AS away_name
            FROM matches m
            JOIN clubs h ON m.home_club_id = h.club_id
            JOIN clubs a ON m.away_club_id = a.club_id
            WHERE (m.home_club_id = ? OR m.away_club_id = ?)
              AND m.match_date BETWEEN ? AND ?
            ORDER BY m.match_date
        ''', (club_id, club_id, date_from, date_to)).fetchall()

    return render_template('report.html', clubs=clubs, matches=matches)


if __name__ == '__main__':
    app.run(debug=True)