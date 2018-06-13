# Где вы очутились
Это проект анализа логов активности sci-hub. Про него большая статья на [хабре](https://habr.com/post/359342/). А это материалы, которые помогут будущему исследователю быстрее пройти рутинные этапы. Кроме того, вы можете порисовать графики аналогичные приведённым в статье.

# Где лежит
Для рисования графиков распакуйте архив `counts_and_heatmaps.7z` и откройте блокнот `PlotsForPaper.ipynb` в jupyter notebook.
Вам понадобится третий python (библиотеки перечислены в `requirements.txt`), какой-нибудь современный ruby (и пакет tzinfo), набор стандартных GNU-утилит и нестандартная утилита sponge из moreutils.

Если вы хотите повторить анализ с нуля, загляните в `workflow.txt`. Это не воспроизводимый скрипт, а скорее лабораторный журнал, описывающий, что я делал. А также гигабайт 60-70 свободного места на диске и лишняя неделя времени, на которую вас засосёт изучение этих логов.

В проекте много лишних файлов, скриптов и стадий, которые не использовались в итоговом анализе. Я в описании workflow я старался отметить, какие пункты в итоге были отброшены.

С вопросами **можно** писать в телеграм `@VorontsovIE` и на почту - `vorontsov.i.e.@you-know-that-google-mail-system.com`.