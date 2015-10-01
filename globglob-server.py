import os
from flask import Flask, request, render_template
import json


app = Flask(__name__)


best_filename = 'globglob_bestscore.txt'


def retrieve_best():
    if not os.path.exists(best_filename):
        store_best(0)
    with open(best_filename, 'r') as f:
        return int(f.read())


def store_best(score):
    with open(best_filename, 'w+') as f:
        f.write(str(score))


@app.route('/best', methods=['GET', 'POST'])
def best():
    current_best = retrieve_best()
    if request.method == 'POST':
        score = int(request.form['score'])
        if score > current_best:
            store_best(score)
            current_best = score
    return json.dumps(dict(result=current_best))


@app.route('/')
def home():
    return render_template('index.html')


if __name__ == '__main__':
    app.run(debug=True)
