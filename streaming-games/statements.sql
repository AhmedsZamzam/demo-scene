CREATE STREAM USER_GAME (USER_KEY STRUCT<USER VARCHAR, GAME_NAME VARCHAR > KEY, GAME STRUCT<SCORE INT, LIVES INT, LEVEL INT>) WITH (KAFKA_TOPIC='USER_GAME', KEY_FORMAT='JSON', VALUE_FORMAT='JSON');
CREATE STREAM USER_LOSSES (USER_KEY STRUCT<USER VARCHAR, GAME_NAME VARCHAR > ) WITH (KAFKA_TOPIC='USER_LOSSES', KEY_FORMAT='JSON', VALUE_FORMAT='JSON');
CREATE TABLE LOSSES_PER_USER AS SELECT USER_KEY, USER_KEY->USER AS USER, USER_KEY->GAME_NAME AS GAME_NAME, COUNT(USER_KEY) AS TOTAL_LOSSES FROM USER_LOSSES GROUP BY USER_KEY;
CREATE TABLE STATS_PER_USER AS SELECT UG.USER_KEY AS USER_KEY, UG.USER_KEY->USER AS USER, UG.USER_KEY->GAME_NAME AS GAME_NAME, MAX(UG.GAME->SCORE) AS HIGHEST_SCORE, MAX(UG.GAME->LEVEL) AS HIGHEST_LEVEL, MAX(CASE WHEN LPU.TOTAL_LOSSES IS NULL THEN CAST(0 AS BIGINT) ELSE LPU.TOTAL_LOSSES END) AS TOTAL_LOSSES FROM USER_GAME UG LEFT JOIN LOSSES_PER_USER LPU ON UG.USER_KEY = LPU.USER_KEY GROUP BY UG.USER_KEY;