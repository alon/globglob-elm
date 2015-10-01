import os
from flask import Flask, request


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
    if request.method == 'POST':
        store_best(request.form['score'])
        return "ok"
    else:
        return str(retrieve_best())


@app.route('/')
def home():
    return "this is home"


if __name__ == '__main__':
    app.run(debug=True)
