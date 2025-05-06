#!/bin/bash

# Название коммита (по умолчанию "Update")
COMMIT_MESSAGE=${1:-"Update"}

# Название новой ветки (можно передать как параметр)
BRANCH_NAME=${2:-"feature-$(date +%Y%m%d-%H%M%S)"}

# Перейти в папку проекта (замени на реальный путь)
PROJECT_PATH="/Users/o.chetverykov/Desktop/Xcode/FrootyNator Juice Master"

if [[ ! -d "$PROJECT_PATH" ]]; then
    echo "❌ Ошибка: Папка проекта не найдена!"
    exit 1
fi

cd "$PROJECT_PATH" || exit

# Проверить, есть ли изменения
if [[ -n $(git status --porcelain) ]]; then
    echo "📌 Обнаружены изменения, выполняю коммит..."

    # Добавить файлы и создать коммит
    git add .
    git commit -m "$COMMIT_MESSAGE"

    # Создать новую ветку и переключиться на неё
    git checkout -b "$BRANCH_NAME"

    # Пуш в новую ветку
    git push origin "$BRANCH_NAME"

    echo "✅ Изменения запушены в ветку '$BRANCH_NAME'!"

    # Вывести ссылку для создания Pull Request
    GITHUB_USERNAME="Alexandr3721"
    REPO_NAME="jacksecurity"
    echo "🔗 Создайте Pull Request: https://github.com/$GITHUB_USERNAME/$REPO_NAME/pull/new/$BRANCH_NAME"
else
    echo "⚡ Нет изменений для коммита"
fi
