CustomAchievementsStatic = {
    ["Общие"] = {
        ["Великий открыватор"] = {
            index = 1,
            uniqueIndex = 1,  -- Уникальный индекс
            name = "Великий открыватор",
            description = "Найдите кнопку аддона у миникарты и нажмите ее",
            texture = "Interface\\AddOns\\NSQC3\\emblem.tga",
            rewardPoints = 1,
            requiredAchievements = {},
            send_txt = "нашел кнопку гильдейского аддона и даже сам открыл ее. В первый раз!",
            category = "Общие",
        },
    },
    ["Чат"] = {
        ["Копирайтер"] = {
            index = 2,
            uniqueIndex = 2,  -- Уникальный индекс
            name = "Копирайтер",
            description = "Пишите в гильдчате",
            texture = "Interface\\AddOns\\NSQC3\\libs\\chat_master.tga",
            rewardPoints = 50,
            requiredAchievements = {},
            send_txt = "",
            subAchievements = {"Пассив", "Актив", "Не читатель", "Нейросеть"},
            category = "Чат",
            subAchievements_args = {100, 1000, 10000, 100000},
            achievement_args = 100000,
            achFunc = "copiwriter"
        },
        ["Пассив"] = {
            index = 3,
            uniqueIndex = 3,  -- Уникальный индекс
            name = "Пассив",
            description = "Напишите 100 сообщений в гильдчате",
            texture = "Interface\\AddOns\\NSQC3\\libs\\100.tga",
            rewardPoints = 1,
            requiredAchievements = {},
            send_txt = "",
            category = "Чат"
        },
        ["Актив"] = {
            index = 4,
            uniqueIndex = 4,  -- Уникальный индекс
            name = "Актив",
            description = "Напишите 1000 сообщений в гильдчате",
            texture = "Interface\\AddOns\\NSQC3\\libs\\1000.tga",
            rewardPoints = 5,
            requiredAchievements = {},
            send_txt = "",
            category = "Чат"
        },
        ["Не читатель"] = {
            index = 5,
            uniqueIndex = 5,  -- Уникальный индекс
            name = "Не читатель",
            description = "Напишите 10000 сообщений в гильдчате",
            texture = "Interface\\AddOns\\NSQC3\\libs\\10000.tga",
            rewardPoints = 10,
            requiredAchievements = {},
            send_txt = "",
            category = "Чат"
        },
        ["Нейросеть"] = {
            index = 6,
            uniqueIndex = 6,  -- Уникальный индекс
            name = "Нейросеть",
            description = "Напишите 100000 сообщений в гильдчате",
            texture = "Interface\\AddOns\\NSQC3\\libs\\100000.tga",
            rewardPoints = 50,
            requiredAchievements = {},
            send_txt = "",
            category = "Чат"
        },
    },
    ["Поле"] = {
        ["Медитация"] = {
            index = 7,
            uniqueIndex = 7,  -- Уникальный индекс
            name = "Медитация",
            description = "Кликайте всякое",
            texture = "Interface\\AddOns\\NSQC3\\libs\\click.tga",
            rewardPoints = 50,
            requiredAchievements = {},
            send_txt = "",
            category = "Поле",
            subAchievements = {3, 4, 5, 6},
            achievement_args = 100000,
            subAchievements_args = {100, 1000, 10000, 100000},
            achFunc = "meditacia"
        },
    }
}
ns_tooltips = {
    ["00t"] = {
        mod = 1,
        viewHP = 999,
        tooltips = {
            "|cFF6495EDОпределенно это дерево...",
            "|cffFFCF40Может у него спросить чего?",
            " ",
            "|cff99ff99ПКМ: |cffFFCF40Рубить дерево"
        }
    },
    ["00f"] = {
        mod = 1,
        viewHP = 999,
        tooltips = {
            "|cFF6495EDГустая трава. Ну видно же!",
            "|cff99ff99ПКМ: |cffFFCF40добывать траву",
            " ",
            "|cffFFCF40шанс получить траву(|cffffffffниже 100 хп|cffFFCF40): |cff99ff991%",
            "|cffFFCF40шанс получить траву(|cffffffffот 100 до 200 хп|cffFFCF40): |cff99ff995%",
            "|cffFFCF40шанс получить траву(|cffffffffот 200 до 500 хп|cffFFCF40): |cff99ff9910%",
            "|cffFFCF40шанс получить траву(|cffffffffот 500 до 900 хп|cffFFCF40): |cff99ff9950%",
            "|cffFFCF40шанс получить траву(|cffffffffвыше 900 хп|cffFFCF40): |cff99ff9990%"
        }
    },
    ["00z"] = {
        mod = 1,
        viewHP = 999,
        tooltips = {
            "|cFF6495EDСлегка рыхлая сырая земля..ее что, копали?"
        }
    },
    ["0ka"] = {
        tooltips = {
            "|cFF6495EDНесокрушимая скала",
            "|cffFFCF40Ее нельзя обидеть, обмануть, разрушить...",
            " ",
            "|cff99ff99ПКМ: |cffFFCF40добывать камень |cff99ff99(шансы: 1 из 500 кликов)"
        }
    },
    ["00h"] = {
        mod = 1,
        viewHP = 999,
        tooltips = {
            "|cFF6495EDХижина",
            "|cffFFCF40Хижина, дом, бла бла. Тут можно получить квест.",
            " ",
            "Я серьезно: |cff99ff99ЛКМ: " .. "|cffFFCF40получить квест",
            "|cff99ff99ПКМ: " .. "|cffFFCF40разрушить"
        }
    },
    ["0hs"] = {
        mod = 1,
        viewHP = 999,
        tooltips = {
            "|cFF6495EDХижина (строительство)",
            " ",
            "|cff99ff99ЛКМ: " .. "|cffFFCF40cтроить",
            "|cff99ff99ПКМ: " .. "|cffFFCF40разрушить"
        }
    },
    ["0uz"] = {
        mod = 1,
        viewHP = 999,
        tooltips = {
            "|cFF6495EDПочти ровная земля. Еще пару топ-топов...",
            " ",
            "|cff99ff99ЛКМ: " .. "|cffFFCF40топтать",
            "|cff99ff99ПКМ: " .. "|cffFFCF40рыть"
        }
    },
    ["0zt"] = {
        mod = 1,
        viewHP = 1,
        tooltips = {
            "|cFF6495EDОчень хорошо утоптанная земля, молодец.",
            " ",
            "|cff99ff99ПКМ: " .. "|cffFFCF40рыть"
        }
    },
    ["0hp"] = {
        tooltips = {
            "",
        }
    },
    ["stl"] = {
        tooltips = {
            "|cFF6495EDДревесина и камень работы неизвестного вандала. Чем то напоминает стол.",
            "|cff99ff99ПКМ: " .. "|cffFFCF40Придумать квест"
        }
    },
    ["0ob"] = {
        tooltips = {
            "|cffFF8C001 |cffFFFFE0Управление гильдией осуществляется путем прямой демократии: 1 игрок - 1 голос*.",
            "|cffFFFFE0*глава гильдии - тот самый игрок, который имеет единственный голос.",
            "|cffFF8C001.1 |cffFFFFE0Орнелла Мути законодательно является лучше Моники Белуччи и любых других актрис (или альтернативных актеров)",
            "|cffFF8C001.2 |cffFFFFE0Незнание устава не освобождает от ответственности и является отягчающим обстоятельством",
            "|cffFF8C002 |cffFFFFE0Торговля в гильдии запрещена",
            "|cffFF8C003 |cffFFFFE0Попрошайничество в гильдии запрещено. Наказание - смерть. Или исключение из гильдии до возможности исполнить приговор",
            "|cffFF8C003.0 |cffFFFFE0Офицеры могут исключать и понижать в звании, исходя из принципа гуманности",
            "|cffFF8C003.1 |cffFFFFE0Строго не рекомендуется давать деньги званиям ниже капитана",
            "|cffFF8C003.2 |cffFFFFE0Прохождение подземелий с новичками ниже вас на 10 уровней или с илвлом на 80 от вашего молчаливо порицается",
            "|cffFFFFE0(офицеры, не стесняйтесь использовать молчаливое порицание для слишком настырных)",
            "|cffFF8C004 |cffFFFFE0Каждый член гильдии имеет право попросить квест и получить за выполнение этого квеста награду",
            "|cffFF8C004.1 |cffFFFFE0Каждый член гильдии имеет право отказаться от квеста и получить следующий квест гораздо сложнее за ту же награду.",
            "|cffFFFFE0(Количество доступных квестов на сутки обнуляется)",
            "|cffFF8C004.2 |cffFFFFE0Гоблины имеют бонусную единицу опыта на каждый гильдлвл",
            "|cffFF8C004.2.1 |cffFFFFE0Вульперы получают половину гоблинского бонуса",
            "|cffFF8C004.3 |cffFFFFE0Каждый член гильдии имеет право ничего не делать, если не хочет",
            "|cffFF8C004.4 |cffFFFFE0Запрещается навязывать другим игрокам свои ценности, насколько бы хороши они ни были. На усмотрение модерации",
            "|cffFF8C004.4.1 |cffFFFFE0Запрещается продолжать беседу на тему, которая не нравится любому участнику чата",
            "|cffFF8C005 |cffFFFFE0Каждый член гильдии имеет право на три необоснованных мата в час.",
            "|cffFFFFE0Каждый последующий мат: понижение в звании до исполняющего обязанности констебля на один час",
            "|cffFF8C005.1 |cffFFFFE0Если женщина или прочий какой беременный ребенок младше 25 лет жалуется на мат, матерящийся понижается в звании",
            "|cffFFFFE0до первого звания на срок пока пожаловавшийся не попросит повысить или не уйдет из гильдии",
            "|cffFF8C005.1.1 |cffFFFFE0За уместностью матов следят офицеры",
            "|cffFF8C005.2 |cffFFFFE0Грамматические ошибки считаются за половину мата",
            "|cffFF8C005.2.1 |cffFFFFE0Персонаж с \"правильным\" уникальным ником имеет право на бонус (на усмотрение ГМа):",
            "|cffFFFFE0- Полностью кириллический односложный ник: 3 опыта",
            "|cffFFFFE0- Односложный ник на латинице: 1 опыта",
            "|cffFF8C005.3 |cffFFFFE0Штрафы для офицеров утроены",
            "|cffFF8C005.4 |cffFFFFE0Все ушедшие в добровольный отпуск, получают запись об этом и на время отпуска понижаются в до минимального звания",
            "|cffFF8C006.1 |cffFFFFE0Офицер всегда прав",
            "|cffFF8C006.3 |cffFFFFE0Верующих может исключать только их персональное божество или глава гильдии лично",
            "|cffFF8C007 |cffFFFFE0АУЕ запрещено (Кик по желанию офицера). (Закон Леджаго)",
            "|cffFF8C007.1 |cffFFFFE0Политика запрещена. Вся, целиком. Все что не относится к игровому миру в данном контексте",
            "|cffFF8C007.2 Запрещено указывать свой город и страну: мут на усмотрение офицеров",
            "|cffFF8C008 |cffFFFFE0Действия направленные на подрыв экономической и политической безопасности гильдии запрещены",
            "|cffFF8C008.2 |cffFFFFE0Необоснованные обвинения вышестоящего офицера запрещены, если вас не поддерживают еще двое игроков вашего ранга или выше",
            "|cffFF8C0013.4 |cffFFFFE0Оскорбление члена гильдии считается клеветой, если оскорбляющего не поддержат минимум двое членов гильдии рангом не ниже оскорбляемого",
            "|cffFFFFE0Наказание назначает оскорбляемый",
            "|cffFF8C0013.4.1 |cffFFFFE0Если оскорбляющего поддерживают двое равных рангом оскорбляемому или выше, все трое понижаются на одно звание",
            "|cffFF8C0013.4.2 |cffFFFFE0Провоцирующий нарушение получат наказание равное нарушившему",
            "|cffFF8C0013.4.3 |cffFFFFE0Офицер имеет право исключить самозванца, маскирующегося под его ник",
            "|cffFF8C0013.4.4 |cffFFFFE0Божество не обязано отчитываться за действия над игроками своего пантеона или не состоящими в пантеонах",
            "|cffFF8C0015 |cffFFFFE0Закон обратной силы не имеет"
        }
    }
}

ns_triggers = {
    ["0zt"] = {
        ["Interface\\AddOns\\NSQC3\\libs\\0hs"] = {
            func = function(cellIndex, textureKey) 
                ns_crtH(cellIndex, textureKey)
            end,
            tooltip = "Построить хижину. Надо же где то жить, логично?",
        },
    },
    ["00z"] = {
        ["Interface\\AddOns\\NSQC3\\libs\\0uz"] = {
            func = function(cellIndex, textureKey) 
                ns_crtH(cellIndex, textureKey)
            end,
            tooltip = "Утоптать и выровнять землю"
        },
    },
    ["0hp"] = {
        -- ["Interface\\AddOns\\NSQC3\\libs\\0hs"] = {
        --     func = function(cellIndex, textureKey) 
        --         ns_crtH(cellIndex, textureKey)
        --     end,
        --     tooltip = "Построить хижину. Надо же где то жить, логично?",
        --     craft = false
        -- },
        ["Interface\\AddOns\\NSQC3\\libs\\00b"] = {
            func = function(cellIndex, textureKey, isCraft) 
                 ns_crtH(cellIndex, textureKey, isCraft)
            end,
            tooltip = "Мастерски установить неструганное бревно",
            craft = true
        },
        ["Interface\\AddOns\\NSQC3\\libs\\0ka"] = {
            func = function(cellIndex, textureKey, isCraft) 
                 ns_crtH(cellIndex, textureKey, isCraft)
            end,
            tooltip = "Брутально установить камень строго в нужное место",
            craft = true
        },
    }
}

ns_recipes = {
    ["Стол"] = {
        ["ресурсы"] = {
            [2] = "00b",
            [12] = "00b",
            [4] = "00b",
            [14] = "00b",
            [21] = "0ka",
            [22] = "0ka",
            [23] = "0ka",
            [24] = "0ka",
            [25] = "0ka",
        },
        ["текстура"] = "stl"
    },
    ["Стул"] = {
        ["ресурсы"] = {
            [1] = "00b",
            [2] = "0ka",
        },
        ["текстура"] = "st1"
    },
    ["Дом"] = {
        ["ресурсы"] = {
            [1] = "00b",
            [2] = "0ka",
            [5] = "00b",
            [6] = "0ka",
        },
        ["текстура"] = "dom"
    },
    ["Тест"] = {
        ["ресурсы"] = {
            [1] = "00b",
            [11] = "00b",
            [21] = "00b",
        },
        ["текстура"] = "tst"
    },
}