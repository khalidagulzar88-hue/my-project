#include <iostream>
#include <windows.h>
#include <ctime>
using namespace std;
const int width = 30;
const int height = 20;
const int maxSize = 100;
struct Position {
    int x, y;
};
Position snake[maxSize];
int size = 1;
int direction = -1;
int foodX, foodY;
bool gameOver = false;
int score = 0;
void moveCursorToTop() {
    COORD coord = {0, 0};
    SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), coord);
}
void draw();
void input();
void logic();

int main() {
    srand(time(0));
    snake[0] = {width / 2, height / 2};
    foodX = rand() % width + 1;
    foodY = rand() % height;
    HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
    CONSOLE_CURSOR_INFO cursorInfo;
    GetConsoleCursorInfo(hOut, &cursorInfo);
    cursorInfo.bVisible = false;
    SetConsoleCursorInfo(hOut, &cursorInfo);
    
    while (!gameOver) {
        moveCursorToTop();
        draw();
        input();
        logic();
        Sleep(150);
    }
    cout << "\nGame Over!\nFinal Score: " << score << endl;
    system("pause");
    return 0;
}
void draw() {
    cout << "Score: " << score << endl;
    for (int i = 0; i < width + 2; i++) cout << "#";
    cout << endl;
    
    for (int i = 0; i < height; i++) {
        for (int j = 0; j < width + 2; j++) {
            if (j == 0 || j == width + 1) {
                cout << "#";
            } else if (i == foodY && j == foodX) {
                cout << "*";
            } else {
                bool printed = false;
                for (int k = 0; k < size; k++) {
                    if (snake[k].x == j && snake[k].y == i) {
                        cout << "O";
                        printed = true;
                        break;
                    }
                }
                if (!printed) cout << " ";
            }
        }
        cout << endl;
    }

    for (int i = 0; i < width + 2; i++) cout << "#";
    cout << endl;
}

void input() {
    if (GetAsyncKeyState(VK_LEFT))  direction = 0;
    if (GetAsyncKeyState(VK_RIGHT)) direction = 1;
    if (GetAsyncKeyState(VK_UP))    direction = 2;
    if (GetAsyncKeyState(VK_DOWN))  direction = 3;
}

void logic() {
    for (int i = size - 1; i > 0; i--) {
        snake[i] = snake[i - 1];
    }
    
    switch (direction) {
        case 0: snake[0].x--; break;
        case 1: snake[0].x++; break;
        case 2: snake[0].y--; break;
        case 3: snake[0].y++; break;
    }
    
    if (snake[0].x <= 0 || snake[0].x >= width + 1 || snake[0].y < 0 || snake[0].y >= height)
        gameOver = true;

    if (snake[0].x == foodX && snake[0].y == foodY) {
        if (size < maxSize) size++;
        score += 10;
        foodX = rand() % width + 1;
        foodY = rand() % height;
    }
}
