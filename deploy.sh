#!/bin/bash

# Название приложения
APP_NAME="FrootyNator Juice Master"
REPO_NAME=$(echo "$APP_NAME" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')

# Ваш GitHub-аккаунт
GITHUB_USERNAME="Alexandr3721"

# Путь к проекту
PROJECT_PATH="/Users/o.chetverykov/Desktop/Xcode/FrootyNator Juice Master"

# Проверяем, установлен ли GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) не установлен! Установите его: https://cli.github.com/"
    exit 1
fi

# Проверяем, авторизован ли GitHub CLI
if ! gh auth status &> /dev/null; then
    echo "❌ GitHub CLI не авторизован. Запустите:"
    echo "gh auth login"
    exit 1
fi

# Создание репозитория, если он не существует
if ! gh repo view "$GITHUB_USERNAME/$REPO_NAME" &> /dev/null; then
    echo "📌 Репозиторий не найден, создаю..."
    gh repo create "$REPO_NAME" --public
else
    echo "✅ Репозиторий уже существует!"
fi

# Переход в папку проекта
cd "$PROJECT_PATH" || { echo "❌ Ошибка: Папка проекта не найдена!"; exit 1; }

# Проверяем, является ли папка Git-репозиторием
if [ ! -d ".git" ]; then
    echo "📌 Инициализирую Git-репозиторий..."
    git init
    git branch -M main
fi

# Удаляем старый origin, если он есть
git remote remove origin 2>/dev/null

# Добавляем новый origin
git remote add origin git@github.com:$GITHUB_USERNAME/$REPO_NAME.git

# Скачиваем изменения перед пушем (избегаем fetch first ошибки)
git pull --rebase origin main || echo "⚠️ Ветки пока нет, продолжаем..."

# Добавляем файлы и пушим
git add .
git commit -m "Initial commit"
git push --force origin main

echo "✅ Репозиторий успешно загружен: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
