-- ============================================================
-- COURSE DATA: MODULES 1-6
-- ============================================================

ns_llua = ns_llua or {}
ns_llua['lua'] = ns_llua['lua'] or {}

ns_llua['lua'][1] = {
    type = "info",
    title = "Введение в Lua",
    content = [=[
<h>Введение в Lua</h>
Lua — это легковесный, динамический язык программирования, основанный на таблицах. Он поддерживает разные стили программирования: императивный, объектно-ориентированный (через таблицы и метатаблицы) и функциональный. Имеет всего несколько типов данных, а основной структурой данных является таблица.

Чаще всего его используют как встраиваемый скриптовый язык в играх и приложениях, но также он работает и самостоятельно — например, в консольных утилитах или веб-серверах.

<h>Переменные и область видимости</h>
В Lua 5.1 переменные могут быть глобальными или локальными.

<t>Локальные переменные</t> — объявляются с ключевым словом <k>local</k>, доступны только в пределах своего блока. Использование локальных переменных делает код быстрее.

<t>Глобальные переменные</t> — объявляются без <k>local</k> и доступны отовсюду, но их использование считается плохой практикой.

<t>Примеры кода:</t>
<code>
<cm>-- Объявление локальной переменной</cm>
<kw>local</kw> userName <op>=</op> <st>'Высшая'</st>

<cm>-- Объявление глобальной переменной</cm>
userName <op>=</op> <st>"Шеф"</st>

<cm>-- Константы принято писать заглавными</cm>
<kw>local</kw> MAX_USERS <op>=</op> <nu>100</nu>
</code>

<w>Примечание:</w> По соглашению, константы (значения, которые не должны меняться) записывают в ВЕРХНЕМ_РЕГИСТРЕ. Хотя язык не запрещает их изменять, хорошей практикой считается этого не делать.
]=],
}

ns_llua['lua'][2] = {
    type = "info",
    title = "Комментарии в Lua",
    content = [=[
<h>Комментарии в Lua</h>
Комментарии — это текст в коде, который игнорируется интерпретатором. Они нужны для пояснения логики, временного отключения кода или оставления заметок для других разработчиков.

<h>Однострочные комментарии</h>
Однострочный комментарий начинается с двух дефисов <c>--</c>. Всё, что находится после них до конца строки, игнорируется при выполнении.

<t>Примеры:</t>
<code>
<cm>-- Это комментарий, он не выполнится</cm>
<kw>local</kw> x <op>=</op> <nu>10</nu>  <cm>-- А это комментарий после кода</cm>
</code>

<h>Многострочные комментарии</h>
Для комментирования больших блоков кода используются многострочные комментарии. Они начинаются с <c>--[[</c> и заканчиваются <c>]]</c>. Всё, что находится между ними, будет проигнорировано.

<t>Пример:</t>
<code>
<cm>--[[
Этот код не выполнится:
local a = 5
local b = 10
print(a + b)
]]</cm>

<cm>-- А это уже выполнится</cm>
<kw>print</kw><op>(</op><st>"Привет, мир!"</st><op>)</op>
</code>
]=],
}

ns_llua['lua'][3] = {
    type = "info",
    title = "Команда /run",
    content = [=[
<h>Команда /run</h>

<t>Назначение:</t> выполнение Lua-кода прямо в игре без создания аддона.

<t>Синтаксис:</t>
<code>
<kw>/run</kw> код
</code>

<t>Примеры для практики:</t>
<code>
<cm>-- Вывод сообщения в чат</cm>
<kw>/run</kw> <kw>print</kw><op>(</op><st>"Hello, World!"</st><op>)</op>

<cm>-- Математические операции</cm>
<kw>/run</kw> <kw>print</kw><op>(</op><nu>2</nu> <op>+</op> <nu>2</nu> <op>*</op> <nu>3</nu><op>)</op>

<cm>-- Создание глобальной переменной</cm>
<kw>/run</kw> myVar <op>=</op> <st>"Привет"</st>

<cm>-- Использование созданной переменной</cm>
<kw>/run</kw> <kw>print</kw><op>(</op>myVar<op>)</op>

<cm>-- Несколько команд в одной строке</cm>
<kw>/run</kw> <kw>local</kw> a<op>=</op><nu>5</nu><op>;</op> <kw>local</kw> b<op>=</op><nu>10</nu><op>;</op> <kw>print</kw><op>(</op>a<op>+</op>b<op>)</op>
</code>

<h>Локальные и глобальные переменные в /run</h>

<t>Важное различие:</t>
<code>
<cm>-- Команда 1: создаём локальную переменную</cm>
<kw>/run</kw> <kw>local</kw> x <op>=</op> <nu>10</nu>

<cm>-- Команда 2: пытаемся вывести x</cm>
<kw>/run</kw> <kw>print</kw><op>(</op>x<op>)</op>  <cm>-- nil! Переменная не существует</cm>
</code>

<t>Почему x равен nil?</t> Потому что <k>local</k> создаёт переменную только внутри текущего блока. Когда команда завершается — переменная уничтожается.

<code>
<cm>-- Команда 1: создаём глобальную переменную</cm>
<kw>/run</kw> y <op>=</op> <nu>20</nu>

<cm>-- Команда 2: выводим y</cm>
<kw>/run</kw> <kw>print</kw><op>(</op>y<op>)</op>  <cm>-- 20! Переменная доступна</cm>
</code>

<t>Почему y доступен?</t> Без <k>local</k> переменная попадает в глобальную область и живёт до перезагрузки интерфейса.

<w>Запомни:</w> Локальные переменные живут только внутри одной команды /run. Глобальные — сохраняются между командами.

<h>Команда /dump</h>

<t>Назначение:</t> улучшенный вывод для отладки. Показывает значение и его структуру.

<t>Отличия от print:</t>
- <k>/dump</k> показывает содержимое таблиц и функций
- Удобен для проверки переменных
- Выводит данные в структурированном виде

<t>Примеры вывода:</t>
<code>
<cm>-- dump с таблицей — показывает структуру</cm>
<kw>/dump</kw> <op>{</op><st>"меч"</st><op>,</op> <st>"щит"</st><op>}</op>

<cm>Dump: value={</cm>
<cm>[1]="меч",</cm>
<cm>[2]="щит"</cm>
<cm>}</cm>
</code>

<h>Функции WoW API</h>
В игре доступно множество встроенных функций:

<code>
<cm>-- Показать имя персонажа</cm>
<kw>/run</kw> <kw>print</kw><op>(</op>UnitName<op>(</op><st>"player"</st><op>)</op><op>)</op>

<cm>-- Показать текущее здоровье</cm>
<kw>/run</kw> <kw>print</kw><op>(</op>UnitHealth<op>(</op><st>"player"</st><op>)</op><op>)</op>

<cm>-- Показать координаты</cm>
<kw>/run</kw> <kw>local</kw> x<op>,</op>y <op>=</op> GetPlayerMapPosition<op>(</op><st>"player"</st><op>)</op><op>;</op> <kw>print</kw><op>(</op>x<op>)</op><op>;</op> <kw>print</kw><op>(</op>y<op>)</op>
</code>

<t>Советы:</t>
- Стрелки вверх/вниз — история команд
- Несколько команд разделяйте <k>;</k> (точка с запятой)

<w>Важно:</w> Глобальные переменные сохраняются до перезагрузки интерфейса (/reload). Это позволяет использовать их для экспериментов и тестов!
]=],
}

ns_llua['lua'][4] = {
    type = "info",
    title = "Типы данных в Lua",
    content = [=[
<h>Типы данных в Lua</h>
Lua имеет 8 основных типов данных. Понимание типов — основа работы с переменными.

<h>nil — отсутствие значения</h>
<t>nil</t> означает "ничего". Единственное значение типа nil.

<code>
<kw>local</kw> empty <op>=</op> <kw>nil</kw>
<kw>local</kw> another  <cm>-- без значения будет nil</cm>
</code>

<h>boolean — логический тип</h>
Два значения: <k>true</k> (истина) и <k>false</k> (ложь).

<code>
<kw>local</kw> isAlive <op>=</op> <kw>true</kw>
<kw>local</kw> isDead <op>=</op> <kw>false</kw>
</code>

<w>Внимание:</w> Только <k>false</k> и <k>nil</k> считаются ложными. 0 и "" — это true!

<h>number — числа (БЕЗ кавычек!)</h>
<t> Золотое правило:</t> Числа пишутся <w>БЕЗ</w> кавычек.

<code>
<kw>local</kw> integer <op>=</op> <nu>42</nu>
<kw>local</kw> float <op>=</op> <nu>3.14</nu>
<kw>local</kw> negative <op>=</op> <op>-</op><nu>10</nu>
</code>

<h>string — строки (В КАВЫЧКАХ!)</h>
<t>Золотое правило:</t> Строки пишутся <w>СТРОГО В</w> кавычках.

<code>
<kw>local</kw> single <op>=</op> <st>'Привет'</st>
<kw>local</kw> double <op>=</op> <st>"Мир"</st>
</code>

<h>Число vs Строка</h>
Даже если <k>print</k> выводит их одинаково, для Lua это РАЗНЫЕ вещи:

<code>
<cm>-- ЧИСЛО 777</cm>
<kw>local</kw> num <op>=</op> <nu>777</nu>
<kw>print</kw><op>(</op>num<op>)</op>           <cm>-- 777</cm>
<kw>print</kw><op>(</op><kw>type</kw><op>(</op>num<op>)</op><op>)</op>      <cm>-- "number"</cm>

<cm>-- СТРОКА "777"</cm>
<kw>local</kw> str <op>=</op> <st>"777"</st>
<kw>print</kw><op>(</op>str<op>)</op>           <cm>-- 777</cm>
<kw>print</kw><op>(</op><kw>type</kw><op>(</op>str<op>)</op><op>)</op>      <cm>-- "string"</cm>
</code>

<h>Фишка Lua: Автоприведение</h>
Lua умная — сама превращает строки в числа и наоборот, смотря по оператору:

<code>
<cm>-- Сложение: строка -> число</cm>
<kw>print</kw><op>(</op><st>"777"</st> <op>+</op> <nu>1</nu><op>)</op>    <cm>-- 778 верно</cm>

<cm>-- Конкатенация: число -> строка</cm>
<kw>print</kw><op>(</op><nu>777</nu> <op>..</op> <nu>1</nu><op>)</op>     <cm>-- "7771" верно</cm>
</code>

<h>Когда будет ОШИБКА?</h>
Автоприведение работает только если строка похожа на число:

<code>
<kw>print</kw><op>(</op><st>"5"</st> <op>+</op> <nu>10</nu><op>)</op>      <cm>-- 15 верно</cm>
<kw>print</kw><op>(</op><st>"Привет"</st> <op>+</op> <nu>10</nu><op>)</op>  <cm>-- ОШИБКА!</cm>
</code>

<h>table — таблицы</h>
Самый мощный тип данных. И массив, и словарь одновременно.

<code>
<cm>-- Как массив</cm>
<kw>local</kw> items <op>=</op> <op>{</op><st>"меч"</st><op>,</op> <st>"щит"</st><op>,</op> <st>"зелье"</st><op>}</op>
<kw>print</kw><op>(</op>items<op>[</op><nu>1</nu><op>]</op><op>)</op>  <cm>-- "меч"</cm>

<cm>-- Как словарь</cm>
<kw>local</kw> player <op>=</op> <op>{</op>
name <op>=</op> <st>"Герой"</st><op>,</op>
level <op>=</op> <nu>10</nu>
<op>}</op>
<kw>print</kw><op>(</op>player<op>.</op>name<op>)</op>  <cm>-- "Герой"</cm>
</code>

<h>Функция type()</h>
Возвращает строку с названием типа переменной:

<code>
<kw>print</kw><op>(</op><kw>type</kw><op>(</op><nu>42</nu><op>)</op><op>)</op>        <cm>-- "number"</cm>
<kw>print</kw><op>(</op><kw>type</kw><op>(</op><st>"текст"</st><op>)</op><op>)</op>   <cm>-- "string"</cm>
<kw>print</kw><op>(</op><kw>type</kw><op>(</op><kw>true</kw><op>)</op><op>)</op>      <cm>-- "boolean"</cm>
<kw>print</kw><op>(</op><kw>type</kw><op>(</op><op>{}</op><op>)</op><op>)</op>        <cm>-- "table"</cm>
<kw>print</kw><op>(</op><kw>type</kw><op>(</op><kw>nil</kw><op>)</op><op>)</op>       <cm>-- "nil"</cm>
</code>
]=],
}

ns_llua['lua'][5] = {
    type = "vartest",
    title = "Практика: Типы переменных",
    helpModules = {4, 3},
    tasks = {
        { var = "testNumber", type = "number",  desc = "Создай глобальную переменную testNumber с любым числом" },
        { var = "testString", type = "string",  desc = "Создай глобальную переменную testString с любой строкой" },
        { var = "testBool",   type = "boolean", desc = "Создай глобальную переменную testBool со значением true или false" },
        { var = "testNil",    type = "nil",     desc = "Обнули переменную testNil (сделай /run testNil = nil)" },
        { var = "testTable",  type = "table",   desc = "Создай глобальную переменную testTable с пустой таблицей {}" },
    },
}

ns_llua['lua'][6] = {
    type = "commenttest",
    title = "Практика: Комментарии",
    helpModules = {2},
    requiredPrintCount = 5,
    instruction = "Закомментируй строки 2 и 4, чтобы они не выполнялись. Остальные строки должны работать.",
    initialCode = [=[
print("Строка 1 - должна работать")
print("Строка 2 - закомментируй меня")
print("Строка 3 - должна работать")
print("Строка 4 - закомментируй меня")
print("Строка 5 - должна работать")
]=],
    expectedOutput = "Строка 1 - должна работать\nСтрока 3 - должна работать\nСтрока 5 - должна работать",
}

ns_llua['lua'][7] = {
    type = "info",
    title = "Функция print и форматирование",
    content = [=[
<h>Функция print</h>
<t>print</t> — это основная функция для вывода информации в чат. Она принимает любое количество аргументов и выводит их через табуляцию.

<t>Базовое использование:</t>
<code>
-- Вывод одного значения
print("Привет, мир!")

-- Вывод нескольких значений
print("Игрок:", "Герой", "Уровень:", 10)

-- Вывод чисел и результатов вычислений
print(5 + 3)
</code>

<h>Синтаксический сахар</h>
В Lua можно вызвать print без скобок, если аргумент один и это строка или таблица.

<code>
print "Привет"
print 'Привет'
print [[Привет]]
</code>

<w>Важно:</w> В заданиях курса лучше использовать вариант со скобками: <k>print(...)</k>.

<h>Конкатенация строк</h>
<t>Оператор ..</t> склеивает строки.

<code>
local name = "Герой"
local level = 10

print("Игрок " .. name .. " достиг " .. level .. " уровня")
print("Игрок", name, "достиг", level, "уровня")
</code>

<h>string.format</h>
<t>string.format</t> позволяет собрать строку по шаблону.

<t>Основные заполнители:</t>
- <k>%s</k> — строка
- <k>%d</k> — целое число
- <k>%.2f</k> — число с двумя знаками после запятой

<code>
local name = "Артас"
local level = 80

local message = string.format("%s (ур. %d)", name, level)
print(message)

print(string.format("Золото: %.2f", 1234.5678))
</code>
]=],
}

ns_llua['lua'][8] = {
    type = "printtest",
    title = "Практика: Простой print",
    helpModules = {7, 4},
    content = [=[
<h>Практика: простой print</h>
]=],
    tasks = {
        {
            desc = "Выведи фразу 'HELLO_WOW_123' через print",
            hint = "Используй /run print(\"HELLO_WOW_123\") или /run print('HELLO_WOW_123')",
            pattern = "HELLO_WOW_123",
            expectedExpression = {
                'print("HELLO_WOW_123")',
                "print('HELLO_WOW_123')",
            },
        },
        {
            desc = "Выведи число 777 через print",
            hint = "Используй /run print(777)",
            pattern = "777",
            expectedExpression = "print(777)",
        },
        {
            desc = "Выведи строку '777' через print",
            hint = "Используй /run print(\"777\") или /run print('777')",
            pattern = "777",
            expectedExpression = {
                'print("777")',
                "print('777')",
            },
        },
        {
            desc = "Выведи фразу 'SIMPLE_TEST_OK' через print",
            hint = "Используй /run print(\"SIMPLE_TEST_OK\") или /run print('SIMPLE_TEST_OK')",
            pattern = "SIMPLE_TEST_OK",
            expectedExpression = {
                'print("SIMPLE_TEST_OK")',
                "print('SIMPLE_TEST_OK')",
            },
        },
    },
}

ns_llua['lua'][9] = {
    type = "printtest",
    title = "Практика: Конкатенация",
    helpModules = {7},
    content = [=[
<h>Практика: конкатенация</h>
]=],
    tasks = {
        {
            desc = "Выведи фразу 'FOX BRAVO CHARLIE' через конкатенацию трёх слов с пробелами",
            hint = "Используй /run print(\"FOX\" .. \" BRAVO \" .. \"CHARLIE\")",
            pattern = "FOX BRAVO CHARLIE",
            requireConcat = true,
            requiredConcatCount = 2,
        },
        {
            desc = "Выведи фразу 'WOW-VERSION-335' через конкатенацию с дефисами",
            hint = "Используй /run print(\"WOW-\" .. \"VERSION-\" .. \"335\")",
            pattern = "WOW-VERSION-335",
            requireConcat = true,
            requiredConcatCount = 2,
        },
        {
            desc = "Выведи фразу 'ALPHA BETA GAMMA' через конкатенацию трёх частей с пробелами",
            hint = "Используй /run print(\"ALPHA\" .. \" BETA \" .. \"GAMMA\")",
            pattern = "ALPHA BETA GAMMA",
            requireConcat = true,
            requiredConcatCount = 2,
        },
    },
}

ns_llua['lua'][10] = {
    type = "info",
    title = "Математические операторы",
    content = [=[
<h>Работа с числами</h>
<t>В Lua числа имеют тип <k>number</k>. Отдельного целочисленного типа нет: и <k>7</k>, и <k>3.14</k> — это <k>number</k>.</t>

<code>
local num1 = 7
local num2 = 10
local num3 = num1 + num2

print(num3) -- 17
</code>

<w>Числа пишутся без кавычек, строки — в кавычках.</w>

<h>Основные операции</h>
<t>Над числами можно выполнять сложение, вычитание, умножение, деление, остаток от деления и возведение в степень.</t>

<code>
local a = 7
local b = 2

print(a + b) -- 9 (сложение)
print(a - b) -- 5 (вычитание)
print(a * b) -- 14 (умножение)
print(a / b) -- 3.5 (деление)
print(a % b) -- 1 (остаток от деления)
print(a ^ b) -- 49 (возведение в степень)
print(-a)    -- -7 (унарный минус - смена знака)
</code>

<t>Деление <k>/</k> всегда возвращает число с дробной частью.</t>
<t>Если нужна целая часть, используй <k>math.floor</k>:</t>

<code>
print(math.floor(7 / 2)) -- 3
</code>

<h>Порядок операций</h>
<t>Сначала выполняются умножение, деление и остаток, затем сложение и вычитание. Скобки меняют порядок.</t>

<code>
local num1 = 2 + 3 * 4
local num2 = (2 + 3) * 4

print(num1) -- 14
print(num2) -- 20
</code>

<h>Преобразование строки в число</h>
<t>Для явного преобразования строки в число используется <k>tonumber</k>.</t>

<code>
local s = "1992"
local year = tonumber(s)

print(year + 1) -- 1993
</code>

<t>В математических операциях Lua часто сама превращает строку в число:</t>

<code>
print("5" + 2) -- 7
</code>

<w>Если строка не похожа на число, будет ошибка:</w>

<code>
print("Привет" + 2) -- ошибка
</code>

<h>Преобразование числа в строку</h>
<t>Для явного преобразования числа в строку используется <k>tostring</k>.</t>

<code>
local num = 17
local s = tostring(num)

print(s) -- "17"
</code>

<t>Оператор конкатенации <k>..</k> тоже автоматически превращает число в строку:</t>

<code>
print("Уровень: " .. 80) -- Уровень: 80
</code>

<h>Частые ошибки</h>
<code>
local num = 777
local str = "777"

print(type(num)) -- number
print(type(str)) -- string
</code>

<t>Основные ошибки:</t>
- записать число в кавычках и ожидать числовое поведение;
- ждать целое число после деления <k>/</k>;
- пытаться сложить число со строкой, которая не является числом.
]=],
}

ns_llua['lua'][11] = {
    type = "commenttest",
    title = "Практика: Множественное присваивание",
    helpModules = {1, 3, 4},

    preloadVars = {
        {var = "a", value = 1, desc = "a = 1"},
        {var = "b", value = 2, desc = "b = 2"},
    },

    content = [=[
<h>Множественное присваивание</h>
<t>В Lua можно присваивать значения сразу нескольким переменным в одной строке.</t>

<code>
x, y = 10, 20
</code>

<t>Сначала Lua вычисляет все выражения справа от знака равно, а затем присваивает результаты переменным слева.</t>

<code>
x, y = x + 1, y * 2
</code>

<t>Если справа значений больше, чем слева, лишние значения отбрасываются.</t>
<t>Если слева переменных больше, оставшиеся получают nil.</t>

<code>
local a, b = 1, 2, 3
local c, d = 1
</code>

<t>Эта особенность позволяет обменивать значения переменных без дополнительной переменной.</t>
]=],

    instruction = [=[
<h>Множественное присваивание</h>
<t>В Lua можно присваивать значения сразу нескольким переменным в одной строке.</t>

<code>
x, y = 10, 20
</code>

<t>Сначала Lua вычисляет все выражения справа от знака равно, а затем присваивает результаты переменным слева.</t>

<code>
x, y = x + 1, y * 2
</code>

<t>Если справа значений больше, чем слева, лишние значения отбрасываются.</t>
<t>Если слева переменных больше, оставшиеся получают nil.</t>

<h>Задание</h>
<t>Есть переменные:</t>

<code>
a = 1
b = 2
</code>

<t>Напиши одну строку, которая поменяет значения переменных <k>a</k> и <k>b</k> местами.</t>
<t>Нельзя использовать <k>local</k>, дополнительные переменные и несколько строк.</t>
]=],

    initialCode = [=[
-- Напиши здесь одну строку
]=],

    requireKeywords = {
        "a",
        "b",
        "=",
        ",",
    },

    onlyCodePatterns = true,
    singleLine = true,

    checkCode = function()
        return _G.a == 2 and _G.b == 1
    end,
}

ns_llua['lua'][12] = {
    type = "printtest",
    title = "Практика: GetAchievementInfo и преобразование типов",
    helpModules = {10, 11},

    preloadVars = {
        {
            var = "achieveId",
            value = 944,
            desc = "achieveId = 944 (number)",
        },
        {
            var = "achieveIdStr",
            value = "944",
            desc = 'achieveIdStr = "944" (string)',
        },
        {
            var = "exampleId",
            value = 521,
            desc = "exampleId = 521 (number)",
        },
        {
            var = "exampleIdStr",
            value = "521",
            desc = 'exampleIdStr = "521" (string)',
        },
        {
            var = "achieveName",
            value = "В том тоннеле меня любят!",
            desc = 'achieveName = "В том тоннеле меня любят!" (string)',
        },
        {
            var = "achievePoints",
            value = 15,
            desc = "achievePoints = 15 (number)",
        },
        {
            var = "achieveCompleted",
            value = false,
            desc = "achieveCompleted = false (boolean)",
        },
    },

    content = [=[
<h>Практика: GetAchievementInfo и преобразование типов</h>
<t>В игре есть функция <k>GetAchievementInfo</k>. Она возвращает информацию о достижении.</t>

<t>Посмотрим, как это работает, на примере достижения 521:</t>

<code>
/dump GetAchievementInfo(521)
</code>

<code>
[1]=521,
[2]="Превознесение среди 15 фракций",
[3]=10,
[4]=false,
[8]="Добейтесь того, чтобы вас превозносили 15 фракций.",
[9]=0,
[10]="Interface\Icons\Achievement_Reputation_03",
[11]=""
</code>

<t>То есть функция возвращает сразу несколько значений: ID, название, очки и другие данные.</t>

<t>Чтобы получить нужные значения, используй множественное присваивание:</t>

<code>
local id, name, points = GetAchievementInfo(521)
</code>

<t>В этом задании есть несколько переменных. Среди них есть числа, строки и boolean (узнай какой тип у какой):</t>

<code>
/run print(achieveId, type(achieveId))
/run print(achieveIdStr, type(achieveIdStr))
/run print(exampleId, type(exampleId))
/run print(exampleIdStr, type(exampleIdStr))
/run print(achieveName, type(achieveName))
/run print(achievePoints, type(achievePoints))
/run print(achieveCompleted, type(achieveCompleted))
</code>

<h>Задание 1</h>
<t>Выведи название достижения 944.</t>
<t>Не вставляй число 944 вручную. Используй подходящую переменную, в которой уже лежит число.</t>

<code>
/run local id, name = GetAchievementInfo(___); print(name)
</code>

<h>Задание 2</h>
<t>Снова выведи название достижения 944.</t>
<t>В этот раз используй переменную <k>achieveIdStr</k>. Это строка, поэтому её нужно преобразовать в число.</t>

<code>
/run local id, name = GetAchievementInfo(___); print(name)
</code>
]=],

    tasks = {
        {
            desc = "Выведи название достижения 944, используя правильную переменную",
            hint = "Используй переменную achieveId. Число 944 вручную вставлять нельзя.",
            pattern = "В том тоннеле меня любят!",

            requireKeywords = {
                "local",
                "GetAchievementInfo(achieveId)",
                "print",
            },

            forbidKeywords = {
                "944",
                "achieveIdStr",
                "achieveName",
            },
        },

        {
            desc = "Выведи название достижения 944, преобразовав переменную в число",
            hint = "achieveIdStr — это строка. Её нужно преобразовать в число.",
            pattern = "В том тоннеле меня любят!",

            requireKeywords = {
                "local",
                "GetAchievementInfo",
                "tonumber(achieveIdStr)",
                "print",
            },

            forbidKeywords = {
                "944",
                "achieveName",
            },
        },

    },
}

ns_llua['lua'][13] = {
    type = "printtest",
    title = "Практика: Числа и математика",
    helpModules = {10},
    content = [=[
<h>Практика: числа и математика</h>
]=],
    tasks = {
        {
            desc = "Выведи результат умножения 6 * 7",
            hint = "Используй /run print(6 * 7)",
            pattern = "42",
            expectedExpression = {
                "print(6*7)",
                "print(7*6)",
            },
        },
        {
            desc = "Выведи результат выражения 100 - 25",
            hint = "Используй /run print(100 - 25)",
            pattern = "75",
            expectedExpression = "print(100-25)",
        },
        {
            desc = "Выведи результат выражения 15 + 30 * 2",
            hint = "Используй /run print(15 + 30 * 2)",
            pattern = "75",
            expectedExpression = "print(15+30*2)",
        },
    },
}

ns_llua['lua'][14] = {
    type = "vartest",
    title = "Практика: string.format с переменными",
    helpModules = {7},

    content = [=[
<h>Что такое string.format</h>
<t>string.format</t> — это функция, которая собирает строку по шаблону.

В шаблоне есть специальные метки, а после шаблона перечисляются значения, которые на эти метки подставятся.

<t>Основные метки:</t>
- <k>%s</k> — строка
- <k>%d</k> — целое число
- <k>%.2f</k> — дробное число с двумя знаками после запятой

<t>Зачем это нужно:</t>
Чтобы не склеивать строку кусками через <k>..</k>, а сразу написать красивый и понятный шаблон.

<h>Пример</h>
Выполни готовую команду:

<code>
/run local itemName = "Меч"; local itemLevel = 25; print(string.format("Предмет: %s, уровень: %d", itemName, itemLevel))
</code>

<t>Что здесь происходит:</t>
- Шаблон: <s>"Предмет: %s, уровень: %d"</s>
- Первый аргумент после шаблона: <k>itemName</k>
- Второй аргумент после шаблона: <k>itemLevel</k>
- Метка <k>%s</k> заменяется на <k>itemName</k>
- Метка <k>%d</k> заменяется на <k>itemLevel</k>

<t>Вывод будет:</t>

<code>
Предмет: Меч, уровень: 25
</code>

<w>Важно:</w> Порядок аргументов имеет значение.

Первая метка получает первую переменную, вторая метка — вторую, и так далее.

<c>Здесь использованы local-переменные. Они живут только внутри одной команды /run.</c>

<h>Тест</h>
<t>Теперь создай переменные героя и выведи строку о герое с помощью string.format.</t>
]=],

    tasks = {
        {
            var = "heroName",
            desc = 'Создай глобальную переменную heroName = "Артас"',
            check = function(value)
                return type(value) == "string" and value == "Артас"
            end,
        },
        {
            var = "heroTitle",
            desc = 'Создай глобальную переменную heroTitle = "Король-лич"',
            check = function(value)
                return type(value) == "string" and value == "Король-лич"
            end,
        },
        {
            var = "heroLevel",
            desc = "Создай глобальную переменную heroLevel = 80",
            check = function(value)
                return type(value) == "number" and value == 80
            end,
        },
        {
            var = "heroHP",
            desc = "Создай глобальную переменную heroHP = 25000",
            check = function(value)
                return type(value) == "number" and value == 25000
            end,
        },
    },

    formatTask = {
        instruction = [=[
Используя string.format, выведи строку:

"Герой Артас (Король-лич) - Уровень: 80, HP: 25000"

Шаблон команды (заполни пропуски вместо ___ именами переменных):

/run print(string.format("Герой %s (%s) - Уровень: %d, HP: %d", ___, ___, ___, ___))

Подсказка:
- первый %s — имя героя;
- второй %s — титул героя;
- первый %d — уровень;
- второй %d — здоровье.
]=],
        pattern = "Герой Артас (Король-лич) - Уровень: 80, HP: 25000",
        requireKeywords = {
            "print",
            "string.format",
        },
    },
}

-- ============================================================
-- UI CLASS: MAIN WINDOW + HELP WINDOW + EDITOR
-- ============================================================

local UI = {}
UI.__index = UI

local TEXT_TAGS = {
    h  = "|cFFFFD700",
    k  = "|cFF80FF80",
    c  = "|cFF66CCFF",
    s  = "|cFFFF8080",
    n  = "|cFFFFB830",
    o  = "|cFFCC88FF",
    t  = "|cFFB3B3B3",
    w  = "|cFFFF8080",
    ok = "|cFF00FF00",
}

local CODE_TAGS = {
    kw = "|cFF80FF80",
    cm = "|cFF808080",
    st = "|cFFFF8080",
    nu = "|cFFFFB830",
    op = "|cFFCC88FF",
}

local function trim(s)
    return (s:match("^%s*(.-)%s*$"))
end

local function applyTags(text, tags, closeColor)
    for tag, color in pairs(tags) do
        text = text:gsub("<" .. tag .. ">", color)
        text = text:gsub("</" .. tag .. ">", closeColor)
    end
    return text
end

local function escapePipes(s)
    return (s:gsub("|", "||"))
end

local LUA_KEYWORDS = {
    ["and"] = true,
    ["break"] = true,
    ["do"] = true,
    ["else"] = true,
    ["elseif"] = true,
    ["end"] = true,
    ["false"] = true,
    ["for"] = true,
    ["function"] = true,
    ["if"] = true,
    ["in"] = true,
    ["local"] = true,
    ["nil"] = true,
    ["not"] = true,
    ["or"] = true,
    ["repeat"] = true,
    ["return"] = true,
    ["then"] = true,
    ["true"] = true,
    ["until"] = true,
    ["while"] = true,

    ["print"] = true,
    ["string"] = true,
    ["table"] = true,
    ["math"] = true,
    ["pairs"] = true,
    ["ipairs"] = true,
    ["type"] = true,
    ["tostring"] = true,
    ["tonumber"] = true,
    ["select"] = true,
    ["unpack"] = true,
    ["pcall"] = true,
    ["loadstring"] = true,
}

local function highlightLuaCode(code)
    if type(code) ~= "string" or code == "" then
        return ""
    end

    local out = {}
    local i = 1
    local n = #code

    local DEFAULT  = "|cFF66CCFF"
    local KEYWORD  = "|cFF80FF80"
    local COMMENT  = "|cFF808080"
    local STRING   = "|cFFFF8080"
    local NUMBER   = "|cFFFFB830"
    local OPERATOR = "|cFFCC88FF"
    local RESET    = "|r"

    table.insert(out, DEFAULT)

    while i <= n do
        local c = code:sub(i, i)

        if c == "-" and code:sub(i + 1, i + 1) == "-" then
            local j

            if code:sub(i + 2, i + 3) == "[[" then
                local close = code:find("]]", i + 4, true)
                j = close and (close + 2) or (n + 1)
            else
                local nl = code:find("[\r\n]", i)
                j = nl or (n + 1)
            end

            local token = code:sub(i, j - 1)
            table.insert(out, COMMENT .. escapePipes(token) .. RESET .. DEFAULT)
            i = j

        elseif c == '"' or c == "'" then
            local quote = c
            local j = i + 1

            while j <= n do
                local ch = code:sub(j, j)

                if ch == "\\" then
                    j = j + 2
                elseif ch == quote then
                    j = j + 1
                    break
                else
                    j = j + 1
                end
            end

            local token = code:sub(i, j - 1)
            table.insert(out, STRING .. escapePipes(token) .. RESET .. DEFAULT)
            i = j

        elseif c == "[" and code:sub(i + 1, i + 1) == "[" then
            local close = code:find("]]", i + 2, true)
            local j = close and (close + 2) or (n + 1)

            local token = code:sub(i, j - 1)
            table.insert(out, STRING .. escapePipes(token) .. RESET .. DEFAULT)
            i = j

        elseif c:match("%d") or (c == "." and code:sub(i + 1, i + 1):match("%d")) then
            local num = code:match("^%d+%.%d+", i)
                or code:match("^%d+", i)
                or code:match("^%.%d+", i)
                or c

            table.insert(out, NUMBER .. escapePipes(num) .. RESET .. DEFAULT)
            i = i + #num

        elseif c:match("[%a_]") then
            local word = code:match("^[%a_][%w_]*", i)

            if LUA_KEYWORDS[word] then
                table.insert(out, KEYWORD .. escapePipes(word) .. RESET .. DEFAULT)
            else
                table.insert(out, escapePipes(word))
            end

            i = i + #word

        elseif c:match("[%p]") then
            table.insert(out, OPERATOR .. escapePipes(c) .. RESET .. DEFAULT)
            i = i + 1

        else
            table.insert(out, escapePipes(c))
            i = i + 1
        end
    end

    table.insert(out, RESET)

    return table.concat(out)
end

local function hasManualCodeTags(text)
    return text:find("<kw>", 1, true)
        or text:find("<cm>", 1, true)
        or text:find("<st>", 1, true)
        or text:find("<nu>", 1, true)
        or text:find("<op>", 1, true)
end

local function markupText(text)
    if type(text) ~= "string" or text == "" then
        return ""
    end

    text = escapePipes(text)
    return "|cFFFFFFFF" .. applyTags(text, TEXT_TAGS, "|cFFFFFFFF") .. "|r"
end

local function markupPlain(text)
    if type(text) ~= "string" or text == "" then
        return ""
    end

    return "|cFFFFFFFF" .. escapePipes(text) .. "|r"
end

local function markupCode(text)
    if type(text) ~= "string" or text == "" then
        return ""
    end

    if hasManualCodeTags(text) then
        text = escapePipes(text)
        return "|cFF66CCFF" .. applyTags(text, CODE_TAGS, "|cFF66CCFF") .. "|r"
    end

    return highlightLuaCode(text)
end

local function parseContent(raw)
    local blocks = {}

    if type(raw) ~= "string" or raw == "" then
        return blocks
    end

    local pos = 1

    while true do
        local startPos, endPos, codeText = raw:find("<code>(.-)</code>", pos)
        local textPart = trim(startPos and raw:sub(pos, startPos - 1) or raw:sub(pos))

        if textPart ~= "" then
            table.insert(blocks, { type = "text", content = textPart })
        end

        if not startPos then
            break
        end

        table.insert(blocks, { type = "code", content = trim(codeText) })
        pos = endPos + 1
    end

    return blocks
end

local function clearBlocks(blocks)
    for _, block in ipairs(blocks or {}) do
        block:Hide()
        block:SetParent(nil)
    end
end

local function updateScroll(scrollFrame, content, bar)
    local maxScroll = math.max(0, content:GetHeight() - (scrollFrame:GetHeight() or 1))

    bar:SetMinMaxValues(0, maxScroll)

    local value = bar:GetValue()

    if value > maxScroll then
        value = maxScroll
    end

    if value < 0 then
        value = 0
    end

    if value ~= bar:GetValue() then
        bar:SetValue(value)
    end

    content:ClearAllPoints()
    content:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, value)
end

local function resetScroll(scrollFrame, content, bar)
    if not scrollFrame or not content or not bar then
        return
    end

    bar:SetValue(0)

    content:ClearAllPoints()
    content:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
end

local function layoutBlocks(blocks, parent, scrollFrame, bar)
    local width = parent:GetWidth() or 560
    local y = -5

    local function layoutEditor(block)
        local editWidth = math.max(10, width - 20)
        local innerY = -10

        block:ClearAllPoints()
        block:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
        block:SetWidth(width)

        block._editBox:ClearAllPoints()
        block._editBox:SetPoint("TOPLEFT", block, "TOPLEFT", 10, innerY)
        block._editBox:SetWidth(editWidth)

        block._measure:ClearAllPoints()
        block._measure:SetPoint("TOPLEFT", block, "TOPLEFT", 10, innerY)
        block._measure:SetWidth(editWidth)
        block._measure:SetText(block._editBox:GetText() or "")

        local editHeight = math.max(60, (block._measure:GetStringHeight() or 0) + 12)
        block._editBox:SetHeight(editHeight)
        innerY = innerY - editHeight - 8

        block._button:ClearAllPoints()
        block._button:SetPoint("TOPLEFT", block, "TOPLEFT", 10, innerY)
        innerY = innerY - (block._button:GetHeight() or 22) - 12

        block._previewLabel:ClearAllPoints()
        block._previewLabel:SetPoint("TOPLEFT", block, "TOPLEFT", 10, innerY)
        innerY = innerY - (block._previewLabel:GetStringHeight() or 12) - 4

        block._preview:ClearAllPoints()
        block._preview:SetPoint("TOPLEFT", block, "TOPLEFT", 10, innerY)
        block._preview:SetWidth(editWidth)

        local previewHeight = math.max(16, (block._preview:GetStringHeight() or 0) + 4)
        innerY = innerY - previewHeight - 12

        if block._resultMessage:GetText() and block._resultMessage:GetText() ~= "" then
            block._resultMessage:ClearAllPoints()
            block._resultMessage:SetPoint("TOPLEFT", block, "TOPLEFT", 10, innerY)
            block._resultMessage:SetWidth(editWidth)
            innerY = innerY - (block._resultMessage:GetStringHeight() or 0) - 10
        else
            block._resultMessage:ClearAllPoints()
        end

        local function layoutResultLine(label, text)
            if text:GetText() and text:GetText() ~= "" then
                label:ClearAllPoints()
                label:SetPoint("TOPLEFT", block, "TOPLEFT", 10, innerY)
                innerY = innerY - (label:GetStringHeight() or 12) - 2

                text:ClearAllPoints()
                text:SetPoint("TOPLEFT", block, "TOPLEFT", 10, innerY)
                text:SetWidth(editWidth)
                innerY = innerY - (text:GetStringHeight() or 0) - 10
            else
                label:ClearAllPoints()
                text:ClearAllPoints()
            end
        end

        layoutResultLine(block._expectedLabel, block._expectedText)
        layoutResultLine(block._currentLabel, block._currentText)

        block:SetHeight(math.max(120, -innerY + 10))
        y = y - block:GetHeight() - 8
    end

    for _, block in ipairs(blocks or {}) do
        if block._kind == "editor" then
            layoutEditor(block)
        else
            block:ClearAllPoints()
            block:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
            block:SetWidth(width)

            local fs = block._fs

            if block._kind == "code" then
                fs:SetWidth(math.max(10, width - 24))
                block:SetHeight(math.max(20, (fs:GetStringHeight() or 0) + 16))
            else
                fs:SetWidth(math.max(10, width - 10))
                block:SetHeight(math.max(18, (fs:GetStringHeight() or 0) + 4))
            end

            y = y - block:GetHeight() - 8
        end
    end

    parent:SetHeight(math.max(100, -y + 5))
    updateScroll(scrollFrame, parent, bar)
end

local function createTextBlock(parent, raw)
    local block = CreateFrame("Frame", nil, parent)

    local fs = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetPoint("TOPLEFT", 5, 0)
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    fs:SetNonSpaceWrap(true)
    fs:SetSpacing(3)
    fs:SetText(markupText(raw))

    block._fs = fs
    block._kind = "text"

    return block
end

local function createCodeBlock(parent, raw)
    local block = CreateFrame("Frame", nil, parent)

    local bg = block:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(block)
    bg:SetTexture(0.03, 0.04, 0.07, 1)

    local bar = block:CreateTexture(nil, "ARTWORK")
    bar:SetPoint("TOPLEFT")
    bar:SetPoint("BOTTOMLEFT")
    bar:SetWidth(3)
    bar:SetTexture(0.35, 0.55, 0.95, 1)

    local fs = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetPoint("TOPLEFT", 12, -8)
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    fs:SetNonSpaceWrap(true)
    fs:SetSpacing(2)
    fs:SetText(markupCode(raw))

    block._fs = fs
    block._kind = "code"

    return block
end

local editorCounter = 0

local function createEditorBlock(parent, data, ui)
    editorCounter = editorCounter + 1

    local block = CreateFrame("Frame", nil, parent)
    block._kind = "editor"
    block._name = data.name or ("editor" .. editorCounter)

    local bg = block:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(block)
    bg:SetTexture(0.03, 0.04, 0.07, 1)

    local bar = block:CreateTexture(nil, "ARTWORK")
    bar:SetPoint("TOPLEFT")
    bar:SetPoint("BOTTOMLEFT")
    bar:SetWidth(3)
    bar:SetTexture(0.35, 0.55, 0.95, 1)

    local editBox = CreateFrame("EditBox", nil, block)
    editBox:SetFontObject("GameFontNormal")
    editBox:SetMultiLine(true)
    editBox:SetAutoFocus(false)
    editBox:SetJustifyH("LEFT")
    editBox:SetText(data.code or "")

    local button = CreateFrame("Button", nil, block, "UIPanelButtonTemplate")
    button:SetSize(130, 22)
    button:SetText(data.buttonText or "Выполнить")

    local previewLabel = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    previewLabel:SetText("|cFFB3B3B3Подсветка кода:|r")

    local preview = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    preview:SetJustifyH("LEFT")
    preview:SetJustifyV("TOP")
    preview:SetNonSpaceWrap(true)
    preview:SetSpacing(2)
    preview:SetText(markupCode(data.code or ""))

    local resultMessage = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    resultMessage:SetJustifyH("LEFT")
    resultMessage:SetJustifyV("TOP")
    resultMessage:SetNonSpaceWrap(true)
    resultMessage:SetSpacing(2)
    resultMessage:SetText("")

    local expectedLabel = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    expectedLabel:SetJustifyH("LEFT")
    expectedLabel:SetText("")

    local expectedText = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    expectedText:SetJustifyH("LEFT")
    expectedText:SetJustifyV("TOP")
    expectedText:SetNonSpaceWrap(true)
    expectedText:SetSpacing(2)
    expectedText:SetText("")

    local currentLabel = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentLabel:SetJustifyH("LEFT")
    currentLabel:SetText("")

    local currentText = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    currentText:SetJustifyH("LEFT")
    currentText:SetJustifyV("TOP")
    currentText:SetNonSpaceWrap(true)
    currentText:SetSpacing(2)
    currentText:SetText("")

    local measure = block:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    measure:SetJustifyH("LEFT")
    measure:SetJustifyV("TOP")
    measure:SetNonSpaceWrap(true)
    measure:SetAlpha(0)

    editBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    editBox:SetScript("OnTabPressed", function(self)
        self:Insert("    ")
    end)

    editBox:SetScript("OnEnterPressed", function(self)
        if IsControlKeyDown and IsControlKeyDown() then
            button:Click()
        else
            self:Insert("\n")
        end
    end)

    editBox:SetScript("OnTextChanged", function(self)
        preview:SetText(markupCode(self:GetText() or ""))

        if ui then
            ui.layoutDirty = true
        end
    end)

    button:SetScript("OnClick", function()
        editBox:ClearFocus()

        if ui and ui.callbacks and ui.callbacks.onExecute then
            ui.callbacks.onExecute(block._name, editBox:GetText() or "")
        end
    end)

    block._editBox = editBox
    block._button = button
    block._preview = preview
    block._previewLabel = previewLabel
    block._resultMessage = resultMessage
    block._expectedLabel = expectedLabel
    block._expectedText = expectedText
    block._currentLabel = currentLabel
    block._currentText = currentText
    block._measure = measure

    return block
end

local function addBackgroundBorder(frame)
    local border = frame:CreateTexture(nil, "BACKGROUND")
    border:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
    border:SetTexture(0.25, 0.25, 0.35, 1)

    local bg = frame:CreateTexture(nil, "BORDER")
    bg:SetAllPoints(frame)
    bg:SetTexture(0.08, 0.08, 0.12, 0.97)
end

local function createScrollArea(parent, contentWidth, topX, topY, bottomX, bottomY)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent)
    scrollFrame:SetPoint("TOPLEFT", topX, topY)
    scrollFrame:SetPoint("BOTTOMRIGHT", bottomX, bottomY)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetWidth(contentWidth)
    content:SetHeight(100)
    content:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, 0)
    scrollFrame:SetScrollChild(content)

    local bar = CreateFrame("Slider", nil, parent)
    bar:SetPoint("TOPRIGHT", -8, topY - 5)
    bar:SetPoint("BOTTOMRIGHT", -8, bottomY + 3)
    bar:SetWidth(16)
    bar:SetOrientation("VERTICAL")
    bar:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
    bar:SetMinMaxValues(0, 0)
    bar:SetValueStep(1)
    bar:SetValue(0)

    local scrollBg = bar:CreateTexture(nil, "BACKGROUND")
    scrollBg:SetAllPoints(bar)
    scrollBg:SetTexture(0.15, 0.15, 0.20, 1)

    bar:SetScript("OnValueChanged", function(_, value)
        content:ClearAllPoints()
        content:SetPoint("TOPLEFT", scrollFrame, "TOPLEFT", 0, value)
    end)

    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(_, delta)
        local maxScroll = select(2, bar:GetMinMaxValues())
        local value = math.max(0, math.min(bar:GetValue() - delta * 25, maxScroll))
        bar:SetValue(value)
    end)

    return scrollFrame, content, bar
end

local function setButtonEnabled(button, enabled)
    if enabled then
        button:Enable()
        button:SetAlpha(1)
    else
        button:Disable()
        button:SetAlpha(0.45)
    end
end

function UI:new(parent)
    local self = setmetatable({}, UI)

    self.parent = parent or UIParent
    self.callbacks = {}
    self.helpModules = nil
    self.helpKey = nil

    self.blocks = {}
    self.helpBlocks = {}
    self.editors = {}

    self.layoutDirty = false
    self.isScaling = false
    self.scaleStartScale = 1
    self.scaleStartX = 0
    self.scaleStartY = 0

    self:_CreateMain()

    return self
end

function UI:SaveState()
    if not self.frame then
        return
    end

    nsDbc = nsDbc or {}
    nsDbc.luaTest = nsDbc.luaTest or {}

    local point, relativeTo, relativePoint, x, y = self.frame:GetPoint(1)

    nsDbc.luaTest.windowState = {
        point = point or "CENTER",
        relativeTo = (relativeTo and relativeTo.GetName and relativeTo:GetName()) or "UIParent",
        relativePoint = relativePoint or "CENTER",
        x = x or 0,
        y = y or 0,
        scale = self.frame:GetScale() or 1,
    }
end

function UI:LoadState()
    if not self.frame then
        return
    end

    local state = nsDbc and nsDbc.luaTest and nsDbc.luaTest.windowState

    if type(state) ~= "table" then
        return
    end

    local scale = tonumber(state.scale)

    if scale then
        scale = math.max(0.75, math.min(2.0, scale))
        self.frame:SetScale(scale)
    end

    local point = tostring(state.point or "CENTER")
    local relativePoint = tostring(state.relativePoint or point)
    local relativeTo = _G[state.relativeTo or "UIParent"] or UIParent

    local x = tonumber(state.x) or tonumber(state.xOfs) or 0
    local y = tonumber(state.y) or tonumber(state.yOfs) or 0

    self.frame:ClearAllPoints()
    self.frame:SetPoint(point, relativeTo, relativePoint, x, y)
end

function UI:_CreateMain()
    local f = CreateFrame("Frame", nil, self.parent)

    f:SetSize(620, 450)
    f:SetPoint("CENTER")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:SetFrameStrata("HIGH")

    addBackgroundBorder(f)

    local titleBg = f:CreateTexture(nil, "ARTWORK")
    titleBg:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    titleBg:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    titleBg:SetHeight(35)
    titleBg:SetTexture(0.15, 0.15, 0.20, 1)

    local titleSeparator = f:CreateTexture(nil, "ARTWORK")
    titleSeparator:SetPoint("TOPLEFT", titleBg, "BOTTOMLEFT", 0, 0)
    titleSeparator:SetPoint("TOPRIGHT", titleBg, "BOTTOMRIGHT", 0, 0)
    titleSeparator:SetHeight(2)
    titleSeparator:SetTexture(0.30, 0.30, 0.50, 1)

    local bottomBg = f:CreateTexture(nil, "ARTWORK")
    bottomBg:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 0, 0)
    bottomBg:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
    bottomBg:SetHeight(38)
    bottomBg:SetTexture(0.12, 0.12, 0.18, 1)

    local bottomSeparator = f:CreateTexture(nil, "ARTWORK")
    bottomSeparator:SetPoint("BOTTOMLEFT", bottomBg, "TOPLEFT", 0, 0)
    bottomSeparator:SetPoint("BOTTOMRIGHT", bottomBg, "TOPRIGHT", 0, 0)
    bottomSeparator:SetHeight(2)
    bottomSeparator:SetTexture(0.30, 0.30, 0.50, 1)

    local closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        self:HideHelp()

        if self.callbacks.onClose then
            self.callbacks.onClose()
        end

        f:Hide()
    end)

    local helpButton = CreateFrame("Button", nil, f)
    helpButton:SetSize(24, 24)
    helpButton:SetPoint("TOPRIGHT", -30, -5)

    local helpButtonText = helpButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    helpButtonText:SetAllPoints(helpButton)
    helpButtonText:SetText("?")
    helpButtonText:SetTextColor(0.8, 0.8, 0.2, 1)

    helpButton:SetScript("OnClick", function()
        if self.callbacks.onHelp then
            self.callbacks.onHelp(self.helpModules)
        end
    end)

    self.helpButton = helpButton

    self.titleText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.titleText:SetPoint("LEFT", f, "LEFT", 15, 0)
    self.titleText:SetPoint("RIGHT", helpButton, "LEFT", -8, 0)
    self.titleText:SetPoint("TOP", titleBg, "TOP", 0, -8)
    self.titleText:SetJustifyH("LEFT")

    self.scrollFrame, self.contentFrame, self.scrollBar = createScrollArea(f, 560, 18, -45, -28, 45)

    self.moduleText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.moduleText:SetPoint("BOTTOM", f, "BOTTOM", 0, 14)
    self.moduleText:SetTextColor(0.6, 0.6, 0.7, 1)

    self.prevButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    self.prevButton:SetSize(110, 24)
    self.prevButton:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 15, 8)
    self.prevButton:SetText("<  Назад")
    self.prevButton:SetScript("OnClick", function()
        if self.callbacks.onPrev then
            self.callbacks.onPrev()
        end
    end)

    self.nextButton = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    self.nextButton:SetSize(110, 24)
    self.nextButton:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -15, 8)
    self.nextButton:SetText("Вперед  >")
    self.nextButton:SetScript("OnClick", function()
        if self.callbacks.onNext then
            self.callbacks.onNext()
        end
    end)

    local scaleButton = CreateFrame("Button", nil, f)
    scaleButton:SetSize(18, 18)
    scaleButton:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -3, 3)
    scaleButton:SetFrameLevel(f:GetFrameLevel() + 10)
    scaleButton:EnableMouse(true)

    local scaleTexture = scaleButton:CreateTexture(nil, "ARTWORK")
    scaleTexture:SetAllPoints(scaleButton)
    scaleTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")

    scaleButton:SetScript("OnEnter", function()
        scaleTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    end)

    scaleButton:SetScript("OnLeave", function()
        scaleTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    end)

    scaleButton:RegisterForDrag("LeftButton")

    scaleButton:SetScript("OnDragStart", function()
        self.isScaling = true
        self.scaleStartScale = f:GetScale() or 1
        self.scaleStartX, self.scaleStartY = GetCursorPosition()
    end)

    scaleButton:SetScript("OnDragStop", function()
        self.isScaling = false
        self:SaveState()
    end)

    f:RegisterForDrag("LeftButton")

    f:SetScript("OnDragStart", function(frame)
        frame:StartMoving()
    end)

    f:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        self:SaveState()
    end)

    f:SetScript("OnUpdate", function()
        if self.layoutDirty then
            self.layoutDirty = false
            self:Layout()
        end

        if self.isScaling then
            local mx, my = GetCursorPosition()
            local dx = mx - self.scaleStartX
            local dy = my - self.scaleStartY

            local newScale = self.scaleStartScale + (dx - dy) / 1000
            newScale = math.max(0.75, math.min(2.0, newScale))

            local currentScale = f:GetScale() or 1

            if math.abs(newScale - currentScale) > 0.001 then
                f:SetScale(newScale)
            end
        end
    end)

    f:SetScript("OnShow", function()
        if not self.stateLoaded then
            self.stateLoaded = true
            self:LoadState()
        end

        self.layoutDirty = true
    end)

    self.frame = f

    self:LoadState()

    f:SetScript("OnHide", function()
        self.isScaling = false
        self:SaveState()
    end)

    f:Hide()
end

function UI:_CreateHelp()
    if self.helpFrame then
        return
    end

    local f = CreateFrame("Frame", nil, UIParent)

    f:SetSize(700, 580)
    f:SetPoint("CENTER", 40, 0)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:SetFrameStrata("DIALOG")

    addBackgroundBorder(f)

    local titleBg = f:CreateTexture(nil, "ARTWORK")
    titleBg:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    titleBg:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    titleBg:SetHeight(30)
    titleBg:SetTexture(0.15, 0.15, 0.20, 1)

    local titleSeparator = f:CreateTexture(nil, "ARTWORK")
    titleSeparator:SetPoint("TOPLEFT", titleBg, "BOTTOMLEFT", 0, 0)
    titleSeparator:SetPoint("TOPRIGHT", titleBg, "BOTTOMRIGHT", 0, 0)
    titleSeparator:SetHeight(2)
    titleSeparator:SetTexture(0.30, 0.30, 0.50, 1)

    local closeButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function()
        f:Hide()
    end)

    local titleText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("LEFT", f, "LEFT", 15, 0)
    titleText:SetPoint("RIGHT", closeButton, "LEFT", -8, 0)
    titleText:SetPoint("TOP", titleBg, "TOP", 0, -5)
    titleText:SetText("Справка")

    self.helpScroll, self.helpContent, self.helpBar = createScrollArea(f, 650, 15, -40, -25, 15)

    f:RegisterForDrag("LeftButton")

    f:SetScript("OnDragStart", function(frame)
        frame:StartMoving()
    end)

    f:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
    end)

    self.helpFrame = f
    f:Hide()
end

function UI:SetCallbacks(callbacks)
    self.callbacks = callbacks or {}
end

function UI:Show()
    self.frame:Show()
end

function UI:Hide()
    self:HideHelp()
    self.frame:Hide()
end

function UI:IsShown()
    return self.frame:IsShown()
end

function UI:HideHelp()
    if self.helpFrame then
        self.helpFrame:Hide()
    end
end

function UI:SetTitle(text)
    self.titleText:SetText(text or "")
end

function UI:SetModuleInfo(index, total)
    self.moduleText:SetText(string.format("Модуль %d из %d", index or 0, total or 0))
end

function UI:SetPrevEnabled(enabled)
    setButtonEnabled(self.prevButton, enabled)
end

function UI:SetNextEnabled(enabled)
    setButtonEnabled(self.nextButton, enabled)
end

function UI:SetHelpData(helpModules)
    self.helpModules = (type(helpModules) == "table" and #helpModules > 0) and helpModules or nil
    setButtonEnabled(self.helpButton, self.helpModules ~= nil)
end

function UI:Layout()
    if not self.contentFrame then
        return
    end

    layoutBlocks(self.blocks, self.contentFrame, self.scrollFrame, self.scrollBar)

    if self.pendingScrollValue then
        local maxScroll = select(2, self.scrollBar:GetMinMaxValues()) or 0
        local value = math.max(0, math.min(self.pendingScrollValue, maxScroll))

        self.scrollBar:SetValue(value)
        self.pendingScrollValue = nil
    end
end

function UI:LayoutHelp()
    if not self.helpContent then
        return
    end

    layoutBlocks(self.helpBlocks, self.helpContent, self.helpScroll, self.helpBar)
end

function UI:Render(blocks, resetScrollToTop)
    if resetScrollToTop == nil then
        resetScrollToTop = true
    end

    if self.editors then
        for _, editor in pairs(self.editors) do
            if editor._editBox then
                editor._editBox:ClearFocus()
            end
        end
    end

    clearBlocks(self.blocks)

    self.blocks = {}
    self.editors = {}

    for _, data in ipairs(blocks or {}) do
        local block

        if data.type == "code" then
            block = createCodeBlock(self.contentFrame, data.content or "")
        elseif data.type == "editor" then
            block = createEditorBlock(self.contentFrame, data, self)
            self.editors[block._name] = block
        else
            block = createTextBlock(self.contentFrame, data.content or "")
        end

        table.insert(self.blocks, block)
    end

    self:Layout()

    if resetScrollToTop then
        resetScroll(self.scrollFrame, self.contentFrame, self.scrollBar)
        self.pendingScrollValue = nil
    end

    self.layoutDirty = true
end

function UI:RenderHelp(raw)
    clearBlocks(self.helpBlocks)
    self.helpBlocks = {}

    for _, data in ipairs(parseContent(raw)) do
        local block

        if data.type == "code" then
            block = createCodeBlock(self.helpContent, data.content or "")
        else
            block = createTextBlock(self.helpContent, data.content or "")
        end

        table.insert(self.helpBlocks, block)
    end

    self:LayoutHelp()
    resetScroll(self.helpScroll, self.helpContent, self.helpBar)

    self.helpFrame:SetScript("OnUpdate", function(f)
        f:SetScript("OnUpdate", nil)
        self:LayoutHelp()
    end)
end

function UI:SetModuleContent(data)
    data = data or {}

    self:HideHelp()

    -- Если мы обновляем тот же самый модуль, который уже открыт,
    -- не надо прыгать в начало. Сохраняем текущую позицию скролла.
    local sameModule = self.currentModuleIndex ~= nil
        and self.currentModuleIndex == data.index
        and self.frame
        and self.frame:IsShown()

    if sameModule and self.scrollBar then
        self.pendingScrollValue = self.scrollBar:GetValue()
    else
        self.pendingScrollValue = nil
    end

    self.currentModuleIndex = data.index

    self:SetTitle(data.title)
    self:SetModuleInfo(data.index, data.total)
    self:SetPrevEnabled(data.prevEnabled)
    self:SetNextEnabled(data.nextEnabled)
    self:SetHelpData(data.helpModules)

    if data.rawContent then
        self:Render(parseContent(data.rawContent), not sameModule)
    else
        self:Render(data.blocks, not sameModule)
    end

    self:Show()
end

function UI:ShowHelp(helpModules)
    if type(helpModules) ~= "table" or #helpModules == 0 then
        return
    end

    self:_CreateHelp()

    local key = table.concat(helpModules, ",")

    if self.helpFrame:IsShown() and self.helpKey == key then
        self.helpFrame:Hide()
        return
    end

    self.helpKey = key

    local db = ns_llua and ns_llua['lua'] or {}
    local raw = ""

    for _, moduleNumber in ipairs(helpModules) do
        local module = db[moduleNumber]

        if module and module.content then
            if raw ~= "" then
                raw = raw .. "\n\n<c>━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</c>\n\n"
            end

            raw = raw .. module.content
        end
    end

    if raw == "" then
        self.helpFrame:Hide()
        return
    end

    self:RenderHelp(raw)
    self.helpFrame:Show()
end

function UI:GetEditor(name)
    if not self.editors then
        return nil
    end

    return self.editors[name]
end

function UI:GetEditorText(name)
    local editor = self:GetEditor(name)

    if not editor or not editor._editBox then
        return ""
    end

    return editor._editBox:GetText() or ""
end

function UI:SetEditorText(name, code)
    local editor = self:GetEditor(name)

    if not editor or not editor._editBox then
        return
    end

    code = code ~= nil and tostring(code) or ""

    editor._editBox:SetText(code)
    editor._preview:SetText(markupCode(code))

    self.layoutDirty = true
end

function UI:ClearEditorResult(name)
    local editor = self:GetEditor(name)

    if not editor then
        return
    end

    editor._resultMessage:SetText("")
    editor._expectedLabel:SetText("")
    editor._expectedText:SetText("")
    editor._currentLabel:SetText("")
    editor._currentText:SetText("")

    self.layoutDirty = true
end

function UI:SetEditorButtonEnabled(name, enabled)
    local editor = self:GetEditor(name)

    if not editor or not editor._button then
        return
    end

    setButtonEnabled(editor._button, enabled)
end

function UI:SetEditorResult(name, result)
    local editor = self:GetEditor(name)

    if not editor then
        return
    end

    result = result or {}

    local status = result.status or "info"
    local color = "|cFFFFFFFF"

    if status == "success" then
        color = "|cFF00FF00"
    elseif status == "error" then
        color = "|cFFFF8080"
    elseif status == "diff" then
        color = "|cFFFFB830"
    end

    local message = result.message ~= nil and tostring(result.message) or ""
    local expected = result.expected ~= nil and tostring(result.expected) or ""
    local current = result.current ~= nil and tostring(result.current) or ""

    if message ~= "" then
        editor._resultMessage:SetText(color .. escapePipes(message) .. "|r")
    else
        editor._resultMessage:SetText("")
    end

    if expected ~= "" then
        editor._expectedLabel:SetText("|cFFFFD700Ожидаемый результат:|r")
        editor._expectedText:SetText(markupPlain(expected))
    else
        editor._expectedLabel:SetText("")
        editor._expectedText:SetText("")
    end

    if current ~= "" then
        editor._currentLabel:SetText("|cFFFFD700Текущий результат:|r")
        editor._currentText:SetText(markupPlain(current))
    else
        editor._currentLabel:SetText("")
        editor._currentText:SetText("")
    end

    self.layoutDirty = true
end

-- ============================================================
-- END UI CLASS
-- ============================================================


-- ============================================================
-- TEST FUNCTION
-- ============================================================

function TestCourseUI(moduleNumber)
    moduleNumber = tonumber(moduleNumber) or 1

    local db = ns_llua and ns_llua['lua'] or {}
    local m = db[moduleNumber]

    if not m then
        print("TestCourseUI: модуль не найден: " .. tostring(moduleNumber))
        return
    end

    if not TestCourseUIFrame or not TestCourseUIFrame.SetModuleContent then
        TestCourseUIFrame = UI:new(UIParent)
    end

    local ui = TestCourseUIFrame

    ui:SetCallbacks({
        onPrev = function()
            print("UI signal: prev")
        end,

        onNext = function()
            print("UI signal: next")
        end,

        onClose = function()
            print("UI signal: close")
        end,

        onHelp = function(helpModules)
            ui:ShowHelp(helpModules or {1, 2})
        end,

        onExecute = function(editorName, code)
            print("UI signal: execute " .. tostring(editorName))

            ui:SetEditorResult(editorName, {
                status = "diff",
                message = "Заглушка: второй класс ещё не готов.",
                expected = m.expectedOutput or "Ожидаемый результат",
                current = code,
            })
        end,
    })

    local blocks = nil

    if m.type == "vartest" then
        blocks = {
            {
                type = "text",
                content = "<h>Задание: типы переменных</h>\n"
                    .. "Используй <k>/run</k> чтобы создать глобальные переменные нужного типа.\n"
                    .. "<w>Важно:</w> переменные должны быть глобальными (без <k>local</k>)!\n"
                    .. "<t>Пример:</t> <c>/run testNumber = 42</c>",
            },
        }

        if m.preloadVars then
            for _, v in ipairs(m.preloadVars) do
                table.insert(blocks, {
                    type = "text",
                    content = "<c>[i] " .. (v.desc or v.var) .. "</c>",
                })
            end
        end

        for _, task in ipairs(m.tasks or {}) do
            table.insert(blocks, {
                type = "text",
                content = "<t>[ ] " .. task.desc .. "</t>",
            })
        end

        if m.formatTask then
            table.insert(blocks, {
                type = "text",
                content = "<h>Задание на форматирование</h>\n" .. (m.formatTask.instruction or ""),
            })
        end

    elseif m.type == "commenttest" then
        blocks = {
            {
                type = "text",
                content = "<h>Задание: комментарии</h>\n" .. (m.instruction or ""),
            },
            {
                type = "editor",
                name = "commenttest",
                buttonText = "Проверить",
                code = m.initialCode or "",
            },
        }
    end

    ui:SetModuleContent({
        title = m.title,
        index = moduleNumber,
        total = #db,
        prevEnabled = moduleNumber > 1,
        nextEnabled = moduleNumber < #db,
        helpModules = m.helpModules or {1, 2},
        rawContent = blocks and nil or m.content,
        blocks = blocks,
    })
end

-- ============================================================
-- END TEST FUNCTION
-- ============================================================


function TestCourseUI(moduleNumber)
    moduleNumber = tonumber(moduleNumber) or 1

    local db = ns_llua and ns_llua['lua'] or {}
    local m = db[moduleNumber]

    if not m then
        print("TestCourseUI: модуль не найден: " .. tostring(moduleNumber))
        return
    end

    if not TestCourseUIFrame or not TestCourseUIFrame.SetModuleContent then
        TestCourseUIFrame = UI:new(UIParent)
    end

    local ui = TestCourseUIFrame

    ui:SetCallbacks({
        onPrev = function()
            print("UI signal: prev")
        end,

        onNext = function()
            print("UI signal: next")
        end,

        onClose = function()
            print("UI signal: close")
        end,

        onHelp = function(helpModules)
            ui:ShowHelp(helpModules or {1, 2})
        end,

        onExecute = function(editorName, code)
            print("UI signal: execute " .. tostring(editorName))

            -- Это заглушка ответа от второго класса.
            -- Потом здесь будет реальная проверка.
            ui:SetEditorResult(editorName, {
                status = "diff", -- success / error / diff / info
                message = "Заглушка: второй класс ещё не готов.",
                expected = m.expectedOutput or "Ожидаемый результат",
                current = code,
            })
        end,
    })

    local blocks = nil

    if m.type == "vartest" then
        blocks = {
            {
                type = "text",
                content = "<h>Задание: типы переменных</h>\n"
                    .. "Используй <k>/run</k> чтобы создать глобальные переменные нужного типа.\n"
                    .. "<w>Важно:</w> переменные должны быть глобальными (без <k>local</k>)!\n"
                    .. "<t>Пример:</t> <c>/run testNumber = 42</c>",
            },
        }

        if m.preloadVars then
            for _, v in ipairs(m.preloadVars) do
                table.insert(blocks, {
                    type = "text",
                    content = "<c>[i] " .. (v.desc or v.var) .. "</c>",
                })
            end
        end

        for _, task in ipairs(m.tasks or {}) do
            table.insert(blocks, {
                type = "text",
                content = "<t>[ ] " .. task.desc .. "</t>",
            })
        end

        if m.formatTask then
            table.insert(blocks, {
                type = "text",
                content = "<h>Задание на форматирование</h>\n" .. (m.formatTask.instruction or ""),
            })
        end

    elseif m.type == "commenttest" then
        blocks = {
            {
                type = "text",
                content = "<h>Задание: комментарии</h>\n" .. (m.instruction or ""),
            },
            {
                type = "editor",
                name = "commenttest",
                buttonText = "Проверить",
                code = m.initialCode or "",
            },
        }
    end

    ui:SetModuleContent({
        title = m.title,
        index = moduleNumber,
        total = #db,
        prevEnabled = moduleNumber > 1,
        nextEnabled = moduleNumber < #db,
        helpModules = {1, 2},
        rawContent = blocks and nil or m.content,
        blocks = blocks,
    })
end






































local function TrimString(s)
    return (tostring(s or ""):match("^%s*(.-)%s*$"))
end

local function NormalizeLines(s)
    s = tostring(s or "")
    s = s:gsub("\r\n", "\n")

    local lines = {}

    for line in s:gmatch("[^\n]+") do
        line = TrimString(line)
        if line ~= "" then
            table.insert(lines, line)
        end
    end

    return table.concat(lines, "\n")
end

local Logic = {}
Logic.__index = Logic

function Logic:EnsureSaved()
    nsDbc = nsDbc or {}
    nsDbc.luaTest = nsDbc.luaTest or {}
    nsDbc.luaTest.currentModule = nsDbc.luaTest.currentModule or 1
    nsDbc.luaTest.taskDetails = nsDbc.luaTest.taskDetails or {}
end

function Logic:SaveModuleProgress()
    self:EnsureSaved()

    local n = self.current
    nsDbc.luaTest.taskDetails[n] = nsDbc.luaTest.taskDetails[n] or {}

    local done = {}
    if self.done then
        for i, v in pairs(self.done) do
            done[i] = v
        end
    end

    nsDbc.luaTest.taskDetails[n].done = done
    nsDbc.luaTest.taskDetails[n].formatDone = self.formatDone == true
end

function Logic:SaveCommentTest(code, passed)
    self:EnsureSaved()

    local n = self.current
    nsDbc.luaTest.taskDetails[n] = nsDbc.luaTest.taskDetails[n] or {}

    nsDbc.luaTest.taskDetails[n].currentCode = code

    if passed ~= nil then
        nsDbc.luaTest.taskDetails[n].commentTestPassed = passed == true
        nsDbc.luaTest.taskDetails[n].completed = passed == true
    end
end

function Logic:InstallRunScript()
    if self._runScriptInstalled then
        return
    end

    self._runScriptInstalled = true

    local function resetIfModuleChanged()
        if self.runtimeModule ~= self.current then
            self.runtimeModule = self.current
            self.lastExecutedCode = nil
            self.lastPrintMessage = nil
            self.pendingConcatCount = nil
            self.insideRunScript = false
        end
    end

    self._originalPrint = _G.NSQC3_OriginalPrint or print
    _G.NSQC3_OriginalPrint = self._originalPrint

    print = function(...)
        resetIfModuleChanged()

        local parts = {}

        for i = 1, select("#", ...) do
            local value = select(i, ...)
            parts[i] = tostring(value)
        end

        self.lastPrintMessage = table.concat(parts, "\t")

        if not self.insideRunScript then
            self.lastExecutedCode = nil
            self.pendingConcatCount = nil
        end

        local result = self._originalPrint(...)

        self:CheckPrintTasks()

        return result
    end

    self._originalRunScript = _G.NSQC3_OriginalRunScript or RunScript
    _G.NSQC3_OriginalRunScript = self._originalRunScript

    if type(self._originalRunScript) == "function" then
        RunScript = function(code)
            resetIfModuleChanged()

            code = tostring(code or "")

            self.lastExecutedCode = code

            local concatCount = 0

            for _ in code:gmatch("%.%.") do
                concatCount = concatCount + 1
            end

            self.pendingConcatCount = concatCount > 0 and concatCount or nil
            self.lastPrintMessage = nil
            self.insideRunScript = true

            local result = self._originalRunScript(code)

            self.insideRunScript = false

            return result
        end
    end
end

function Logic:CheckPrintTasks()
    local m = self.db and self.db[self.current]

    if not m then
        return
    end

    if TrimString(m.type) ~= "printtest" then
        return
    end

    if not m.tasks then
        return
    end

    self.done = self.done or {}

    local msg = self.lastPrintMessage

    if not msg then
        return
    end

    local function normText(s)
        return tostring(s or ""):gsub("%s+", "")
    end

    local function normCode(s)
        s = tostring(s or "")

        -- Убираем комментарии, чтобы их можно было не учитывать
        -- при проверке ключевых слов и запрещённых слов.
        s = s:gsub("%-%-%[%[.-%]%]", "")
        s = s:gsub("%-%-[^\n]*", "")

        -- Убираем пробелы и конечные точки с запятой.
        s = s:gsub("%s+", "")
        s = s:gsub(";+$", "")

        return s
    end

    local changed = false

    for i, task in ipairs(m.tasks) do
        if not self.done[i] then
            local outputOk = true

            if task.pattern then
                outputOk = normText(msg) == normText(task.pattern)
            end

            local codeOk = true
            local code = normCode(self.lastExecutedCode or "")

            -- Старая проверка expectedExpression.
            -- Она осталась для совместимости со старыми модулями.
            if task.expectedExpression then
                codeOk = false

                if self.lastExecutedCode then
                    if type(task.expectedExpression) == "table" then
                        for _, expr in ipairs(task.expectedExpression) do
                            if code == normCode(expr) then
                                codeOk = true
                                break
                            end
                        end
                    else
                        codeOk = code == normCode(task.expectedExpression)
                    end
                end
            end

            -- Новая проверка: в коде должны быть указанные ключевые слова.
            if task.requireKeywords then
                for _, keyword in ipairs(task.requireKeywords) do
                    local cleanKeyword = tostring(keyword):gsub("%s+", "")

                    if cleanKeyword ~= "" and not code:find(cleanKeyword, 1, true) then
                        codeOk = false
                        break
                    end
                end
            end

            -- Новая проверка: в коде не должно быть запрещённых слов.
            if codeOk and task.forbidKeywords then
                for _, keyword in ipairs(task.forbidKeywords) do
                    local cleanKeyword = tostring(keyword):gsub("%s+", "")

                    if cleanKeyword ~= "" and code:find(cleanKeyword, 1, true) then
                        codeOk = false
                        break
                    end
                end
            end

            local concatOk = true

            if task.requireConcat then
                concatOk = (self.pendingConcatCount or 0) >= (tonumber(task.requiredConcatCount) or 0)
            end

            if outputOk and codeOk and concatOk then
                self.done[i] = true
                changed = true

                if PlaySoundFile then
                    PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\punto.ogg")
                end
            end

            break
        end
    end

    if not changed then
        return
    end

    local all = true

    for i in ipairs(m.tasks) do
        if not self.done[i] then
            all = false
            break
        end
    end

    self.allDone = all

    self:SaveModuleProgress()
    self:SendModuleToUI()

    if all then
        if PlaySoundFile then
            PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\fin.ogg")
        end

        if SendAddonMessage then
            SendAddonMessage("ns_Win", tostring(self.current or 0), "GUILD")
        end
    end
end

function Logic:new(ui, modules)
    local self = setmetatable({}, Logic)

    self.ui = ui
    self.db = modules or {}
    self.current = 1
    self.total = #self.db
    self.done = {}
    self.formatDone = false
    self.timer = nil
    self.nilSeen = {}
    self.allDone = false
    self.commentTestPassed = false

    self.lastExecutedCode = nil
    self.lastPrintMessage = nil
    self.pendingConcatCount = nil
    self.insideRunScript = false
    self.runtimeModule = nil

    self.ui:SetCallbacks({
        onNext = function()
            self:ManageCourse("next")
        end,

        onPrev = function()
            self:ManageCourse("prev")
        end,

        onHelp = function(helpModules)
            self.ui:ShowHelp(helpModules)
        end,

        onExecute = function(editorName, code)
            self:CheckCode(editorName, code)
        end,
    })

    self:InstallRunScript()

    return self
end

function Logic:ManageCourse(signal)
    self.total = #self.db

    if self.total == 0 then
        return
    end

    self:EnsureSaved()

    if signal == "next" then
        if self.current < self.total then
            self.current = self.current + 1
        end
    elseif signal == "prev" then
        if self.current > 1 then
            self.current = self.current - 1
        end
    else
        self.current = tonumber(signal)
            or tonumber(nsDbc.luaTest.currentModule)
            or 1

        if self.current < 1 then
            self.current = 1
        end

        if self.current > self.total then
            self.current = self.total
        end
    end

    nsDbc.luaTest.currentModule = self.current

    self.runtimeModule = self.current
    self.lastExecutedCode = nil
    self.lastPrintMessage = nil
    self.pendingConcatCount = nil
    self.insideRunScript = false

    if self.timer then
        if self.timer.Hide then
            self.timer:Hide()
        end

        if self.timer.Cancel then
            self.timer:Cancel()
        end

        self.timer = nil
    end

    self.allDone = false
    self.nilSeen = {}
    self.commentTestPassed = false

    local m = self.db[self.current]
    local saved = nsDbc.luaTest.taskDetails[self.current]

    self.done = {}
    self.formatDone = false

    if m and saved then
        if m.tasks and type(saved.done) == "table" then
            for i in ipairs(m.tasks) do
                if saved.done[i] or saved.done[tostring(i)] then
                    self.done[i] = true
                end
            end
        end

        self.formatDone = saved.formatDone == true
        self.commentTestPassed = saved.commentTestPassed == true
    end

    if m and m.preloadVars then
        for _, v in ipairs(m.preloadVars) do
            local var = TrimString(v.var)
            if var ~= "" then
                _G[var] = v.value
            end
        end
    end

    if m and m.tasks then
        for i, task in ipairs(m.tasks) do
            local var = TrimString(task.var)
            local taskType = TrimString(task.type)

            if taskType == "nil"
                and var ~= ""
                and not self.done[i]
                and _G[var] == nil then
                    _G[var] = true
            end
        end
    end

    self:SendModuleToUI()

    local mtype = TrimString(m and m.type)

    if m and (mtype == "vartest" or mtype == "customtest") and m.tasks then
        local f = CreateFrame("Frame", nil, UIParent)
        local t = 0

        f:SetScript("OnUpdate", function(_, dt)
            t = t + dt

            if t >= 0.5 then
                t = 0
                self:CheckVars()
            end
        end)

        self.timer = f
        self:CheckVars()
    end

    self.ui:Show()
end

function Logic:SendModuleToUI()
    local n = self.current or 1
    local m = self.db[n]

    if not m then
        return
    end

    self.done = self.done or {}
    self.formatDone = self.formatDone or false

    local mtype = TrimString(m.type)

    local practice = mtype == "vartest"
        or mtype == "printtest"
        or mtype == "customtest"

    local raw = m.content or ""

    if practice and raw == "" then
        raw = "<h>" .. (m.title or "Практика") .. "</h>"
    end

    if practice then
        if m.preloadVars then
            for _, v in ipairs(m.preloadVars) do
                local var = TrimString(v.var)
                local info = TrimString(v.desc or var)

                if var ~= "" and not info:find("<k>", 1, true) then
                    info = info:gsub(var, "<k>" .. var .. "</k>")
                end

                raw = raw .. "\n<c>[i] " .. info .. "</c>"
            end
        end

        if m.tasks then
            for i, task in ipairs(m.tasks) do
                local var = TrimString(task.var)
                local desc = TrimString(task.desc or var or ("Задание " .. i))

                if var ~= "" and not desc:find("<k>", 1, true) then
                    desc = desc:gsub(var, "<k>" .. var .. "</k>")
                end

                if self.done[i] then
                    raw = raw .. "\n<ok>[x] " .. desc .. "</ok>"
                else
                    raw = raw .. "\n<t>[ ] " .. desc .. "</t>"
                end
            end
        end

        if m.formatTask then
            local desc = TrimString(m.formatTask.instruction or "")

            raw = raw .. "\n<h>Задание на форматирование</h>\n"

            if self.formatDone then
                raw = raw .. "<ok>[x] " .. desc .. "</ok>"
            else
                raw = raw .. "<t>[ ] " .. desc .. "</t>"
            end
        end
    end

    local nextEnabled = true

    if mtype == "vartest" or mtype == "customtest" or mtype == "printtest" then
        if m.tasks then
            for i in ipairs(m.tasks) do
                if not self.done[i] then
                    nextEnabled = false
                    break
                end
            end
        end

        if mtype == "vartest" and m.formatTask then
            nextEnabled = nextEnabled and self.formatDone == true
        end
    end

    if mtype == "commenttest" then
        nextEnabled = self.commentTestPassed == true
    end

    local data = {
        title = m.title or "",
        index = n,
        total = self.total or #self.db,
        prevEnabled = n > 1,
        nextEnabled = nextEnabled,
        helpModules = m.helpModules,
    }

    if mtype == "commenttest" then
        self:EnsureSaved()

        local saved = nsDbc.luaTest.taskDetails[n]
        local code = (saved and saved.currentCode) or m.initialCode or ""

        if type(code) ~= "string" then
            code = tostring(code)
        end

        local blocks = {}

        -- Теперь instruction парсится как обычный контент курса.
        -- То есть внутри можно использовать <code>...</code>,
        -- и такие места будут отрисованы как блоки кода с подсветкой.
        for _, block in ipairs(parseContent(m.instruction or "")) do
            table.insert(blocks, block)
        end

        table.insert(blocks, {
            type = "editor",
            name = "commenttest",
            buttonText = "Проверить",
            code = code,
        })

        data.blocks = blocks
    else
        data.rawContent = raw
    end

    self.ui:SetModuleContent(data)

    if mtype == "commenttest" and self.commentTestPassed then
        self.ui:SetEditorButtonEnabled("commenttest", false)
    end
end

local function CheckCodeKeywords(code, requireKeywords, onlyKeywords, singleLine)
    code = tostring(code or "")

    -- Убираем комментарии.
    -- Сначала многострочные, потом однострочные.
    local noComments = code:gsub("%-%-%[%[.-%]%]", "")
    noComments = noComments:gsub("%-%-[^\n]*", "")

    -- Убираем пробелы и конечные точки с запятой.
    local cleanCode = noComments:gsub("%s+", ""):gsub(";+$", "")

    if singleLine then
        local lines = 0

        for line in noComments:gmatch("[^\r\n]+") do
            if line:match("%S") then
                lines = lines + 1
            end
        end

        if lines > 1 then
            return false, "Можно использовать только одну строку кода."
        end

        -- Если внутри остался ;, значит это уже несколько команд в одной строке.
        if cleanCode:find(";", 1, true) then
            return false, "Нельзя использовать несколько команд через точку с запятой."
        end
    end

    -- 1. Проверка, что все обязательные слова присутствуют.
    for _, keyword in ipairs(requireKeywords or {}) do
        local cleanKeyword = tostring(keyword):gsub("%s+", "")

        if cleanKeyword ~= "" and not cleanCode:find(cleanKeyword, 1, true) then
            return false, "В коде не хватает обязательного слова: " .. cleanKeyword
        end
    end

    -- 2. Если включён флаг onlyKeywords / onlyCodePatterns,
    --    проверяем, что в коде нет ничего лишнего.
    if onlyKeywords then
        local tokens = {}

        for _, keyword in ipairs(requireKeywords or {}) do
            local cleanKeyword = tostring(keyword):gsub("%s+", "")

            if cleanKeyword ~= "" then
                table.insert(tokens, cleanKeyword)
            end
        end

        -- Сначала удаляем более длинные токены.
        -- Например, string.format нужно удалять раньше, чем string.
        table.sort(tokens, function(a, b)
            return #a > #b
        end)

        local check = cleanCode

        for _, token in ipairs(tokens) do
            -- Безопасно экранируем спецсимволы Lua-паттернов.
            local escaped = token:gsub("([^%w])", "%%%1")
            check = check:gsub(escaped, "")
        end

        if check ~= "" then
            return false, "Можно использовать только указанные слова и символы."
        end
    end

    return true
end

function Logic:CheckVars()
    self.done = self.done or {}
    self.nilSeen = self.nilSeen or {}

    local m = self.db and self.db[self.current]
    if not m then
        return
    end

    local mtype = TrimString(m.type)
    if mtype ~= "vartest" and mtype ~= "customtest" then
        return
    end

    if not m.tasks then
        return
    end

    local changed = false

    for i, task in ipairs(m.tasks) do
        local var = TrimString(task.var)
        local taskType = TrimString(task.type)

        local value = nil
        if var ~= "" then
            value = _G[var]
        end

        local ok = false

        if task.check then
            local success, result = pcall(task.check, value)
            ok = success and result
        elseif taskType == "nil" then
            if var ~= "" and value ~= nil then
                self.nilSeen[var] = true
            end

            ok = var ~= ""
                and self.nilSeen[var] == true
                and type(value) == "nil"
        elseif taskType ~= "" then
            ok = type(value) == taskType
        end

        if ok and not self.done[i] then
            self.done[i] = true
            changed = true

            if PlaySoundFile then
                PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\punto.ogg")
            end
        end
    end

    local allTasks = true
    for i in ipairs(m.tasks) do
        if not self.done[i] then
            allTasks = false
            break
        end
    end

    if mtype == "vartest" and m.formatTask and allTasks and not self.formatDone then
        local msg = self.lastPrintMessage
        local code = self.lastExecutedCode

        if msg and code then
            local function normLine(s)
                return tostring(s or ""):gsub("%s+", " "):match("^%s*(.-)%s*$")
            end

            local outputOk = normLine(msg) == normLine(m.formatTask.pattern)

            local codeOk = true

            if m.formatTask.requireKeywords
                or m.formatTask.onlyCodePatterns
                or m.formatTask.onlyKeywords
                or m.formatTask.singleLine then
                codeOk = CheckCodeKeywords(
                    code,
                    m.formatTask.requireKeywords,
                    m.formatTask.onlyCodePatterns or m.formatTask.onlyKeywords,
                    m.formatTask.singleLine
                )
            end

            if outputOk and codeOk then
                self.formatDone = true
                changed = true

                if PlaySoundFile then
                    PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\punto.ogg")
                end
            end
        end
    end

    local all = allTasks
    if mtype == "vartest" and m.formatTask then
        all = all and self.formatDone == true
    end

    local wasAllDone = self.allDone == true

    if all then
        self.allDone = true

        if self.timer then
            if self.timer.Hide then
                self.timer:Hide()
            end

            if self.timer.Cancel then
                self.timer:Cancel()
            end

            self.timer = nil
        end
    else
        self.allDone = false
    end

    if changed then
        self:SaveModuleProgress()
        self:SendModuleToUI()

        if all and not wasAllDone and mtype == "vartest" then
            if PlaySoundFile then
                PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\fin.ogg")
            end

            if SendAddonMessage then
                SendAddonMessage("ns_Win", tostring(self.current), "GUILD")
            end
        end
    end
end

function Logic:CheckCode(editorName, code)
    -- Если задание уже выполнено, ничего не делаем.
    if self.commentTestPassed then
        return
    end

    local function Trim(s)
        return (tostring(s or ""):match("^%s*(.-)%s*$"))
    end

    local function Normalize(s)
        s = tostring(s or ""):gsub("\r\n", "\n")

        local lines = {}

        for line in s:gmatch("[^\n]+") do
            line = Trim(line)

            if line ~= "" then
                table.insert(lines, line)
            end
        end

        return table.concat(lines, "\n")
    end

    local m = self.db and self.db[self.current]
    local mtype = Trim(m and m.type)

    if not m or mtype ~= "commenttest" then
        return
    end

    editorName = editorName or "commenttest"
    code = code or ""

    -- Сбрасываем preloadVars перед каждой проверкой,
    -- чтобы предыдущая неудачная попытка не портила следующую.
    if m.preloadVars then
        for _, v in ipairs(m.preloadVars) do
            local var = Trim(v.var)

            if var ~= "" then
                _G[var] = v.value
            end
        end
    end

    -- Универсальная проверка ключевых слов для commenttest.
    -- Используется, если в модуле указаны requireKeywords,
    -- onlyCodePatterns / onlyKeywords или singleLine.
    if m.requireKeywords or m.onlyCodePatterns or m.onlyKeywords or m.singleLine then
        local keywordOk, keywordErr = CheckCodeKeywords(
            code,
            m.requireKeywords,
            m.onlyCodePatterns or m.onlyKeywords,
            m.singleLine
        )

        if not keywordOk then
            self.commentTestPassed = false
            self:SaveCommentTest(code, false)
            self.ui:SetNextEnabled(false)

            self.ui:SetEditorResult(editorName, {
                status = "diff",
                message = keywordErr or "Неверный код.",
                expected = m.expectedCode or m.expectedOutput or "",
                current = code,
            })

            return
        end
    end

    local output = {}
    local oldPrint = print

    print = function(...)
        local args = {...}
        local parts = {}

        for i = 1, #args do
            table.insert(parts, tostring(args[i]))
        end

        table.insert(output, table.concat(parts, " "))
    end

    local fn, compileErr

    if type(loadstring) == "function" then
        fn, compileErr = loadstring(code)
    else
        compileErr = "loadstring недоступен"
    end

    local ok, runErr = false, nil

    if fn then
        ok, runErr = pcall(fn)
    else
        runErr = compileErr
    end

    print = oldPrint

    local current = table.concat(output, "\n")

    if not ok then
        if current ~= "" then
            current = current .. "\nОшибка: " .. tostring(runErr)
        else
            current = "Ошибка: " .. tostring(runErr)
        end
    end

    local problems = {}

    local outputOk = true

    if m.expectedOutput then
        outputOk = Normalize(current) == Normalize(m.expectedOutput)

        if not outputOk then
            table.insert(problems, "Неверный вывод.")
        end
    end

    local printCount = 0
    local templateOk = true
    local needPrint = tonumber(m.requiredPrintCount)

    if needPrint then
        local codeForCheck = code:gsub('"[^"]*"', '""'):gsub("'[^']*'", "''")
        local searchPos = 1

        while true do
            local startPos, endPos = codeForCheck:find("print", searchPos, true)

            if not startPos then
                break
            end

            local before = startPos > 1 and codeForCheck:sub(startPos - 1, startPos - 1) or ""
            local after = codeForCheck:sub(endPos + 1, endPos + 1) or ""

            local beforeIsWord = before ~= "" and before:match("[%w_]") ~= nil
            local afterIsWord = after ~= "" and after:match("[%w_]") ~= nil

            if not beforeIsWord and not afterIsWord then
                printCount = printCount + 1
            end

            searchPos = endPos + 1
        end

        if printCount ~= needPrint then
            templateOk = false
            table.insert(problems, ("В коде должно быть %d слов print. Найдено: %d."):format(needPrint, printCount))
        end
    end

    local runtimeOk = true

    if type(m.checkCode) == "function" then
        if not ok then
            runtimeOk = false
        else
            local success, result = pcall(m.checkCode)
            runtimeOk = success and result == true
        end

        if not runtimeOk then
            table.insert(problems, "Проверка результата не пройдена.")
        end
    end

    local runOk = true

    -- Если модуль не проверяет вывод и не проверяет результат функцией,
    -- то код как минимум должен выполниться без ошибки.
    if not ok and not m.expectedOutput and type(m.checkCode) ~= "function" then
        runOk = false
        table.insert(problems, "Ошибка выполнения кода.")
    end

    local passed = outputOk and templateOk and runtimeOk and runOk

    self.commentTestPassed = passed
    self:SaveCommentTest(code, passed)

    local displayCurrent = current

    if needPrint then
        if displayCurrent ~= "" then
            displayCurrent = displayCurrent .. "\n"
        end

        displayCurrent = displayCurrent .. ("Найдено print: %d из %d"):format(printCount, needPrint)
    end

    if displayCurrent == "" and m.expectedCode then
        displayCurrent = code
    end

    if passed then
        self.ui:SetEditorResult(editorName, {
            status = "success",
            message = "Задание выполнено!",
            expected = m.expectedCode or m.expectedOutput or "",
            current = displayCurrent,
        })

        self.ui:SetNextEnabled(true)
        self.ui:SetEditorButtonEnabled(editorName, false)

        if PlaySoundFile then
            PlaySoundFile("Interface\\AddOns\\NSQC3\\libs\\fin.ogg")
        end

        if SendAddonMessage then
            SendAddonMessage("ns_Win", tostring(self.current), "GUILD")
        end
    else
        local message = table.concat(problems, " ")

        if message == "" then
            message = "Неверно."
        end

        self.ui:SetEditorResult(editorName, {
            status = "diff",
            message = message,
            expected = m.expectedCode or m.expectedOutput or "",
            current = displayCurrent,
        })

        self.ui:SetNextEnabled(false)
    end
end

logic = Logic:new(UI:new(UIParent), ns_llua and ns_llua['lua'] or {})









































































































































-- ========================================================================
-- NSReminder — напоминалка о прохождении курса Lua
-- ========================================================================

local NSReminder = {}
NSReminder.__index = NSReminder

local REMINDER_MESSAGES = {
    "Твои переменные скучают по тебе...",
    "Код сам себя не напишет!",
    "Lua ждёт тебя!",
    "Таблицы плачут без тебя",
    "Принц Артас ждёт твоего кода",
    "Прокрастинируешь?",
    "Один цикл и ты уже разработчик!",
    "string.format зовёт тебя домой",
    "Кто не учит Lua — тот не гильдмастер!",
    "Ещё один модуль и ты почти программист",
    "print('С возвращением!')",
    "Шеф уже спрашивает про твой прогресс",
    "Фарм подождёт, знания — нет",
    "Метатаблицы сами себя не объяснят",
    "local ты = 'ленивец' — исправь это!",
    "Твой персонаж уже выучил бы пару заклинаний",
    "while true do print('учи Lua') end",
    "Нажми на меня, чтобы продолжить обучение",
    "Ты не забыл про курс, правда?",
    "Где-то в ГХ плачет один учитель Lua",
    "Твои навыки кодинга ржавеют",
    "Сделай перерыв от фарма — учи Lua",
    "Таблица без данных — это просто {}",
    "Ты ближе к мастерству, чем думаешь",
    "Осталось совсем немного модулей!",
    "Хватит фармить золото, фарми знания",
    "Паладин бы уже давно прошёл этот курс",
    "nil — это то, что будет от твоих навыков",
    "return 'к курсу'",
    "Твоя гильдия гордится тобой... пока",
    "Сделай for i = 1, 10 do study() end",
    "У тебя есть незаконченные дела с Lua",
    "Твой print() молчит уже час",
    "Курс не убежит, но и сам себя не пройдёт",

    -- Новые сообщения
    "Твой прогресс в курсе = nil. Исправь это!",
    "Ошибка: attempt to index 'твой прогресс' (a nil value)",
    "if not course then print('грусть') end",
    "for i = 1, #твоей_лени do stop() end",
    "string.find(твой_день, 'Lua') вернул nil",
    "table.insert(твоя_жизнь, 'Lua')",
    "GetTime() показывает: пора на курс",
    "Твой /run заржавел без практики",
    "Не будь как local-переменная — стань глобальным!",
    "'end' не закрывает твои отговорки",
    "В чате шепчут: '... снова фармит вместо Lua'",
    "Даже мурлоки уже прошли этот курс",
    "Твоя гильдия ждёт не рейд, а твой print()",
    "Если nil — это значение, то твой прогресс — его пример",
    "В Азероте нет патча против лени",
    "Открой курс, пока сервер не ушёл на рестарт",
    "Каждый пропущенный модуль — это -1 к карме",
    "print('Привет') — уже начало пути",
    "local успех = труд + Lua",
    "if ты_тут then return end -- нет, так не выйдет",
    "while not пройден_курс do учись() end",
    "ipairs(дни) ждут твоего return",
    "pairs(отговорки) — бесконечная таблица",
    "tostring(твой_уровень) всё ещё 'новичок'",
    "tonumber('0') — столько модулей ты прошёл сегодня",
    "string.format('%s, пора учиться', UnitName('player'))",
    "UnitExists('target') есть, а цели учиться — нет",
    "UnitHealth('player') в норме, курс — нет",
    "GetMoney() не купит навык программирования",
    "Не давай курсу уйти в garbage collector (хм..а что это вообще?)",
    "Твой скилл пока на уровне testNumber = 1",
    "Даже print('Hello') лучше, чем ничего",
    "Не будь багом — стань фичей",
    "Время фармить не голд, а знания",
}

local ASSET_PAIRS = {
    {
        texture = "Interface\\AddOns\\NSQC3\\libs\\bbb.tga",
        sound   = "Interface\\AddOns\\NSQC3\\libs\\bbb.ogg",
    },
    {
        texture = "Interface\\AddOns\\NSQC3\\libs\\gob.tga",
        sound   = "Interface\\AddOns\\NSQC3\\libs\\gob.ogg",
    },
    {
        texture = "Interface\\AddOns\\NSQC3\\libs\\gom.tga",
        sound   = "Interface\\AddOns\\NSQC3\\libs\\gom.ogg",
    },
}

-- Настройки времени.
local INITIAL_DELAY         = 3          -- первая проверка через 3 секунды после входа
local MIN_REMINDER_INTERVAL = 10 * 60    -- минимум 10 минут
local MAX_REMINDER_INTERVAL = 60 * 60    -- максимум 1 час
local NOT_OPENED_RECHECK    = 60         -- если курс ещё ни разу не открывали
local API_WAIT_TIMEOUT      = 30         -- сколько ждать появления курса

-- Настройки иконки.
local MIN_ICON_SIZE   = 64
local MAX_ICON_SIZE   = 256
local POSITION_OFFSET = 400

-- ========================================================================
-- Вспомогательные функции
-- ========================================================================

local function Trim(s)
    return (tostring(s or ""):match("^%s*(.-)%s*$"))
end

local function IsCourseApiReady()
    if type(ns_llua) ~= "table" or type(ns_llua['lua']) ~= "table" then
        return false
    end

    if _G.logic and type(_G.logic.ManageCourse) == "function" then
        return true
    end

    if type(OpenLuaCourse) == "function" then
        return true
    end

    return false
end

local function HasCourseEverOpened()
    if not nsDbc or type(nsDbc.luaTest) ~= "table" then
        return false
    end

    if nsDbc.luaTest.currentModule ~= nil then
        return true
    end

    if type(nsDbc.luaTest.taskDetails) == "table" and next(nsDbc.luaTest.taskDetails) ~= nil then
        return true
    end

    if type(nsDbc.luaTest.completedModules) == "table" and next(nsDbc.luaTest.completedModules) ~= nil then
        return true
    end

    return false
end

local function IsModuleCompleted(module, saved)
    local mtype = Trim(module.type)

    -- Инфо-модули и модули без типа считаем пройденными.
    if mtype == "" or mtype == "info" then
        return true
    end

    if type(saved) ~= "table" then
        return false
    end

    -- Старый формат сохранений / общий флаг завершения.
    if saved.completed == true then
        return true
    end

    if mtype == "commenttest" then
        return saved.commentTestPassed == true
    end

    if mtype == "vartest" or mtype == "printtest" or mtype == "customtest" then
        if not module.tasks or #module.tasks == 0 then
            if mtype == "vartest" and module.formatTask then
                return saved.formatDone == true or saved.formatTaskComplete == true
            end

            return true
        end

        local allDone = true

        -- Новый формат: saved.done[i]
        if type(saved.done) == "table" then
            for i in ipairs(module.tasks) do
                if not (saved.done[i] or saved.done[tostring(i)]) then
                    allDone = false
                    break
                end
            end

        -- Старый формат: saved.taskStatus
        elseif type(saved.taskStatus) == "table" then
            for i, task in ipairs(module.tasks) do
                local taskSaved

                if mtype == "vartest" and task.var then
                    local var = Trim(task.var)

                    taskSaved = saved.taskStatus[task.var]
                        or saved.taskStatus[var]
                        or saved.taskStatus[i]
                        or saved.taskStatus[tostring(i)]
                else
                    taskSaved = saved.taskStatus[i] or saved.taskStatus[tostring(i)]
                end

                if not (taskSaved and taskSaved.completed == true) then
                    allDone = false
                    break
                end
            end
        else
            return false
        end

        if not allDone then
            return false
        end

        if mtype == "vartest" and module.formatTask then
            return saved.formatDone == true or saved.formatTaskComplete == true
        end

        return true
    end

    return true
end

local function IsCourseFinished()
    if type(ns_llua) ~= "table" or type(ns_llua['lua']) ~= "table" then
        return false
    end

    local details = nsDbc and nsDbc.luaTest and nsDbc.luaTest.taskDetails

    if type(details) ~= "table" then
        details = {}
    end

    local hasModules = false

    for moduleIndex, module in pairs(ns_llua['lua']) do
        if type(moduleIndex) == "number" and type(module) == "table" then
            hasModules = true

            if not IsModuleCompleted(module, details[moduleIndex]) then
                return false
            end
        end
    end

    return hasModules
end

local function IsCourseWindowShown()
    if _G.logic and _G.logic.ui and type(_G.logic.ui.IsShown) == "function" then
        return _G.logic.ui:IsShown()
    end

    if _G.activeLuaCourse
        and _G.activeLuaCourse.window
        and type(_G.activeLuaCourse.window.IsShown) == "function" then
        return _G.activeLuaCourse.window:IsShown()
    end

    return false
end

local function OpenCourse()
    if IsCourseWindowShown() then
        return
    end

    if _G.logic and type(_G.logic.ManageCourse) == "function" then
        _G.logic:ManageCourse()
        return
    end

    if type(OpenLuaCourse) == "function" then
        OpenLuaCourse()
    end
end

-- ========================================================================
-- NSReminder
-- ========================================================================

function NSReminder:New()
    local self = setmetatable({}, NSReminder)

    self.frame = nil
    self.icon = nil
    self.label = nil
    self.timerFrame = nil
    self.fadeFrame = nil

    self.mode = "wait"
    self.elapsed = 0
    self.nextDelay = 0

    self.lastModule = nil
    self.iconSize = MIN_ICON_SIZE
    self.suppressClick = false

    return self
end

function NSReminder:Init()
    if self.frame then
        return
    end

    self.frame = CreateFrame("Button", nil, UIParent)

    self.frame:SetFrameStrata("TOOLTIP")
    self.frame:SetFrameLevel(100)
    self.frame:SetSize(MIN_ICON_SIZE, MIN_ICON_SIZE)
    self.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    self.frame:SetMovable(true)
    self.frame:EnableMouse(true)
    self.frame:SetClampedToScreen(true)
    self.frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    self.frame:Hide()

    self.icon = self.frame:CreateTexture(nil, "ARTWORK")
    self.icon:SetAllPoints(self.frame)
    self.icon:SetTexture(ASSET_PAIRS[1].texture)

    self.label = self.frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    self.label:SetPoint("BOTTOM", self.frame, "TOP", 0, 5)
    self.label:SetJustifyH("CENTER")
    self.label:SetWidth(400)
    self.label:SetTextColor(1, 0.84, 0, 1)
    self.label:SetShadowOffset(1, -1)
    self.label:SetShadowColor(0, 0, 0, 1)

    self.frame:SetScript("OnEnter", function(frame)
        GameTooltip:SetOwner(frame, "ANCHOR_TOP")
        GameTooltip:SetText("Напоминание о курсе Lua", 1, 0.84, 0)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFFFFFFFFЛКМ:|r Открыть курс", 1, 1, 1)
        GameTooltip:AddLine("|cFFFFFFFFПКМ:|r Скрыть или перезапустить (рандом 1 из 3)", 1, 1, 1)
        GameTooltip:AddLine("|cFFFFFFFFShift+ЛКМ или СКМ:|r Перетащить", 1, 1, 1)
        GameTooltip:Show()
    end)

    self.frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.frame:SetScript("OnMouseDown", function(frame, button)
        if button == "MiddleButton" then
            frame:StartMoving()
        elseif button == "LeftButton" and IsShiftKeyDown() then
            self.suppressClick = true
            frame:StartMoving()
        end
    end)

    self.frame:SetScript("OnMouseUp", function(frame, button)
        if button == "MiddleButton" or button == "LeftButton" then
            frame:StopMovingOrSizing()
        end
    end)

    self.frame:SetScript("OnClick", function(frame, button)
        if self.suppressClick then
            self.suppressClick = false
            return
        end

        if button == "LeftButton" then
            OpenCourse()
            self:Hide()
            self:ScheduleRandom()
        elseif button == "RightButton" then
            self:OnRightClick()
        end
    end)

    self.frame:SetAlpha(0)

    self.timerFrame = CreateFrame("Frame")
    self.timerFrame:Show()

    self.timerFrame:SetScript("OnUpdate", function(_, elapsed)
        self:OnUpdate(elapsed)
    end)
end

function NSReminder:OnUpdate(elapsed)
    if self.mode ~= "wait" then
        return
    end

    self.elapsed = self.elapsed + elapsed

    if self.elapsed < self.nextDelay then
        return
    end

    self.elapsed = 0

    -- Если курс никогда не открывали — не показываем напоминалку.
    if not HasCourseEverOpened() then
        self:ScheduleNotOpenedRecheck()
        return
    end

    -- Если курс полностью пройден — не показываем, но тихо проверяем снова.
    if IsCourseFinished() then
        self:ScheduleRandom()
        return
    end

    -- Если окно курса сейчас открыто — не мешаем.
    if IsCourseWindowShown() then
        self:ScheduleRandom()
        return
    end

    self:Show()
end

function NSReminder:ScheduleRandom()
    self.mode = "wait"
    self.elapsed = 0
    self.nextDelay = math.random(MIN_REMINDER_INTERVAL, MAX_REMINDER_INTERVAL)

    if self.timerFrame then
        self.timerFrame:Show()
    end
end

function NSReminder:ScheduleNotOpenedRecheck()
    self.mode = "wait"
    self.elapsed = 0
    self.nextDelay = NOT_OPENED_RECHECK

    if self.timerFrame then
        self.timerFrame:Show()
    end
end

function NSReminder:Stop()
    self.mode = "stopped"

    if self.fadeFrame then
        self.fadeFrame:SetScript("OnUpdate", nil)
        self.fadeFrame:Hide()
    end

    if self.timerFrame then
        self.timerFrame:Hide()
    end

    if self.frame then
        self.frame:Hide()
    end
end

function NSReminder:Show()
    if not self.frame then
        return
    end

    local currentModule = nsDbc and nsDbc.luaTest and nsDbc.luaTest.currentModule

    if self.lastModule ~= currentModule then
        self.lastModule = currentModule
        self.iconSize = MIN_ICON_SIZE
    end

    local message = REMINDER_MESSAGES[math.random(#REMINDER_MESSAGES)]
    self.label:SetText(message)

    local asset = ASSET_PAIRS[math.random(#ASSET_PAIRS)]
    self.icon:SetTexture(asset.texture)

    self.frame:SetSize(self.iconSize, self.iconSize)

    local offsetX = math.random(-POSITION_OFFSET, POSITION_OFFSET)
    local offsetY = math.random(-POSITION_OFFSET, POSITION_OFFSET)

    self.frame:ClearAllPoints()
    self.frame:SetPoint("CENTER", UIParent, "CENTER", offsetX, offsetY)

    self.frame:Show()
    self:StartFade(self.frame:GetAlpha(), 1, 0.3)

    if PlaySoundFile then
        PlaySoundFile(asset.sound)
    end

    if self.iconSize < MAX_ICON_SIZE then
        self.iconSize = self.iconSize * 2

        if self.iconSize > MAX_ICON_SIZE then
            self.iconSize = MAX_ICON_SIZE
        end
    end

    -- Иконка висит до клика, таймер пока не нужен.
    self.mode = "shown"

    if self.timerFrame then
        self.timerFrame:Hide()
    end
end

function NSReminder:Hide()
    if not self.frame then
        return
    end

    if not self.frame:IsShown() then
        return
    end

    self:StartFade(self.frame:GetAlpha(), 0, 0.3)
end

function NSReminder:OnRightClick()
    local roll = math.random(1, 3)

    if roll == 3 then
        -- Скрываем до следующей плановой проверки.
        self:Hide()
        self:ScheduleRandom()
    else
        -- Тут же перезапускаем напоминалку.
        self:Hide()
        self:Show()
    end
end

function NSReminder:StartFade(fromAlpha, toAlpha, duration)
    if self.fadeFrame then
        self.fadeFrame:SetScript("OnUpdate", nil)
        self.fadeFrame:Hide()
    end

    if not self.frame then
        return
    end

    self.fadeFrame = CreateFrame("Frame")
    self.fadeFrame:Show()

    local elapsed = 0

    self.fadeFrame:SetScript("OnUpdate", function(frame, dt)
        elapsed = elapsed + dt

        local progress = elapsed / duration

        if progress >= 1 then
            self.frame:SetAlpha(toAlpha)

            if toAlpha == 0 then
                self.frame:Hide()
            end

            frame:SetScript("OnUpdate", nil)
            frame:Hide()
        else
            local currentAlpha = fromAlpha + (toAlpha - fromAlpha) * progress
            self.frame:SetAlpha(currentAlpha)
        end
    end)
end

-- ========================================================================
-- Инициализация при входе в игру
-- ========================================================================

local function InitNSReminder()
    if _G.NSReminderInstance then
        return
    end

    if not UIParent then
        return
    end

    if not IsCourseApiReady() then
        return
    end

    if math.randomseed then
        math.randomseed(tonumber(time and time()) or 0)
    end

    local reminder = NSReminder:New()
    reminder:Init()

    _G.NSReminderInstance = reminder
end

local reminderLoader = CreateFrame("Frame")
reminderLoader:Show()
reminderLoader:RegisterEvent("PLAYER_LOGIN")

reminderLoader:SetScript("OnEvent", function()
    local initFrame = CreateFrame("Frame")
    initFrame:Show()

    local waitElapsed = 0

    initFrame:SetScript("OnUpdate", function(frame, elapsed)
        waitElapsed = waitElapsed + elapsed

        if waitElapsed >= INITIAL_DELAY then
            if IsCourseApiReady() then
                frame:SetScript("OnUpdate", nil)
                frame:Hide()
                InitNSReminder()
            elseif waitElapsed >= INITIAL_DELAY + API_WAIT_TIMEOUT then
                frame:SetScript("OnUpdate", nil)
                frame:Hide()
            end
        end
    end)
end)