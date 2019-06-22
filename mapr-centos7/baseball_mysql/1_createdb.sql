
CREATE DATABASE  IF NOT EXISTS `bballsrc` /*!40100 DEFAULT CHARACTER SET utf8 */;
CREATE DATABASE  IF NOT EXISTS `bballtrg` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `bballsrc`;

SET NAMES utf8mb4;

-- SET FOREIGN_KEY_CHECKS = 0;
-- SET FOREIGN_KEY_CHECKS = 1;

-- Create tables ddl
-- ----------------------------
--  Table structure for `AllstarFull`
-- ----------------------------
DROP TABLE IF EXISTS `AllstarFull`;
CREATE TABLE `AllstarFull` (
  `playerID` varchar(64) NOT NULL,
  `yearID` int(11) NOT NULL,
  `gameNum` int(11) DEFAULT NULL,
  `gameID` varchar(64) NOT NULL,
  `teamID` varchar(64) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `GP` int(11) DEFAULT NULL,
  `startingPos` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`playerID`, `yearID`, `gameID`, `teamID`, `lgID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `Appearances`
-- ----------------------------
DROP TABLE IF EXISTS `Appearances`;
CREATE TABLE `Appearances` (
  `yearID` int(11) NOT NULL,
  `teamID` varchar(64) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `playerID` varchar(64) NOT NULL,
  `G_all` int(11) DEFAULT NULL,
  `GS` varchar(64) DEFAULT NULL,
  `G_batting` int(11) DEFAULT NULL,
  `G_defense` int(11) DEFAULT NULL,
  `G_p` int(11) DEFAULT NULL,
  `G_c` int(11) DEFAULT NULL,
  `G_1b` int(11) DEFAULT NULL,
  `G_2b` int(11) DEFAULT NULL,
  `G_3b` int(11) DEFAULT NULL,
  `G_ss` int(11) DEFAULT NULL,
  `G_lf` int(11) DEFAULT NULL,
  `G_cf` int(11) DEFAULT NULL,
  `G_rf` int(11) DEFAULT NULL,
  `G_of` int(11) DEFAULT NULL,
  `G_dh` varchar(64) DEFAULT NULL,
  `G_ph` varchar(64) DEFAULT NULL,
  `G_pr` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`yearID`, `teamID`, `lgID`, `playerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `AwardsManagers`
-- ----------------------------
DROP TABLE IF EXISTS `AwardsManagers`;
CREATE TABLE `AwardsManagers` (
  `playerID` varchar(64) NOT NULL,
  `awardID` varchar(64) NOT NULL,
  `yearID` int(11) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `tie` varchar(64) DEFAULT NULL,
  `notes` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`playerID`, `awardID`, `yearID`, `lgID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `AwardsPlayers`
-- ----------------------------
DROP TABLE IF EXISTS `AwardsPlayers`;
CREATE TABLE `AwardsPlayers` (
  `playerID` varchar(64) NOT NULL,
  `awardID` varchar(64) NOT NULL,
  `yearID` int(11) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `tie` varchar(64) DEFAULT NULL,
  `notes` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`playerID`, `awardID`, `yearID`, `lgID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `AwardsShareManagers`
-- ----------------------------
DROP TABLE IF EXISTS `AwardsShareManagers`;
CREATE TABLE `AwardsShareManagers` (
  `awardID` varchar(64) NOT NULL,
  `yearID` int(11) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `playerID` varchar(64) NOT NULL,
  `pointsWon` int(11) DEFAULT NULL,
  `pointsMax` int(11) DEFAULT NULL,
  `votesFirst` int(11) DEFAULT NULL,
  PRIMARY KEY(`awardID`, `yearID`, `lgID`, `playerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `AwardsSharePlayers`
-- ----------------------------
DROP TABLE IF EXISTS `AwardsSharePlayers`;
CREATE TABLE `AwardsSharePlayers` (
  `awardID` varchar(64) NOT NULL,
  `yearID` int(11) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `playerID` varchar(64) NOT NULL,
  `pointsWon` int(11) DEFAULT NULL,
  `pointsMax` int(11) DEFAULT NULL,
  `votesFirst` int(11) DEFAULT NULL,
  PRIMARY KEY(`awardID`, `yearID`, `lgID`, `playerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `Batting`
-- ----------------------------
DROP TABLE IF EXISTS `Batting`;
CREATE TABLE `Batting` (
  `playerID` varchar(64) NOT NULL,
  `yearID` int(11) NOT NULL,
  `stintID` int(11) DEFAULT NULL,
  `teamID` varchar(64) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `G` int(11) DEFAULT NULL,
  `AB` int(11) DEFAULT NULL,
  `R` int(11) DEFAULT NULL,
  `H` int(11) DEFAULT NULL,
  `2B` int(11) DEFAULT NULL,
  `3B` int(11) DEFAULT NULL,
  `HR` int(11) DEFAULT NULL,
  `RBI` int(11) DEFAULT NULL,
  `SB` int(11) DEFAULT NULL,
  `CS` int(11) DEFAULT NULL,
  `BB` int(11) DEFAULT NULL,
  `SO` int(11) DEFAULT NULL,
  `IBB` varchar(64) DEFAULT NULL,
  `HBP` varchar(64) DEFAULT NULL,
  `SH` varchar(64) DEFAULT NULL,
  `SF` varchar(64) DEFAULT NULL,
  `GIDP` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`playerID`, `yearID`, `stintID`, `teamID`, `lgID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `BattingPost`
-- ----------------------------
DROP TABLE IF EXISTS `BattingPost`;
CREATE TABLE `BattingPost` (
  `yearID` int(11) NOT NULL,
  `roundID` varchar(64) DEFAULT NULL,
  `playerID` varchar(64) NOT NULL,
  `teamID` varchar(64) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `G` int(11) DEFAULT NULL,
  `AB` int(11) DEFAULT NULL,
  `R` int(11) DEFAULT NULL,
  `H` int(11) DEFAULT NULL,
  `2B` int(11) DEFAULT NULL,
  `3B` int(11) DEFAULT NULL,
  `HR` int(11) DEFAULT NULL,
  `RBI` int(11) DEFAULT NULL,
  `SB` int(11) DEFAULT NULL,
  `CS` varchar(64) DEFAULT NULL,
  `BB` int(11) DEFAULT NULL,
  `SO` int(11) DEFAULT NULL,
  `IBB` int(11) DEFAULT NULL,
  `HBP` varchar(64) DEFAULT NULL,
  `SH` varchar(64) DEFAULT NULL,
  `SF` varchar(64) DEFAULT NULL,
  `GIDP` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`yearID`, `roundID`, `playerID`, `teamID`, `lgID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `CollegePlaying`
-- ----------------------------
DROP TABLE IF EXISTS `CollegePlaying`;
CREATE TABLE `CollegePlaying` (
  `playerID` varchar(64) NOT NULL,
  `schoolID` varchar(64) NOT NULL,
  `yearID` int(11) NOT NULL,
  PRIMARY KEY(`playerID`, `schoolID`, `yearID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



-- ----------------------------
--  Table structure for `Fielding`
-- ----------------------------
DROP TABLE IF EXISTS `Fielding`;
CREATE TABLE `Fielding` (
  `playerID` varchar(64) NOT NULL,
  `yearID` int(11) NOT NULL,
  `stintID` int(11) DEFAULT NULL,
  `teamID` varchar(64) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `POS` varchar(64) DEFAULT NULL,
  `G` int(11) DEFAULT NULL,
  `GS` varchar(64) DEFAULT NULL,
  `InnOuts` varchar(64) DEFAULT NULL,
  `PO` int(11) DEFAULT NULL,
  `A` int(11) DEFAULT NULL,
  `E` int(11) DEFAULT NULL,
  `DP` int(11) DEFAULT NULL,
  `PB` varchar(64) DEFAULT NULL,
  `WP` varchar(64) DEFAULT NULL,
  `SB` varchar(64) DEFAULT NULL,
  `CS` varchar(64) DEFAULT NULL,
  `ZR` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`playerID`, `yearID`, `stintid`, `teamID`, `lgID`, `POS`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `FieldingOF`
-- ----------------------------
DROP TABLE IF EXISTS `FieldingOF`;
CREATE TABLE `FieldingOF` (
  `playerID` varchar(64) NOT NULL,
  `yearID` int(11) NOT NULL,
  `stintID` int(11) DEFAULT NULL,
  `Glf` int(11) DEFAULT NULL,
  `Gcf` int(11) DEFAULT NULL,
  `Grf` int(11) DEFAULT NULL,
  PRIMARY KEY(`playerID`, `yearID`, `stintID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `FieldingOFsplit`
-- ----------------------------
DROP TABLE IF EXISTS `FieldingOFsplit`;
CREATE TABLE `FieldingOFsplit` (
  `playerID` varchar(64) NOT NULL,
  `yearID` int(11) NOT NULL,
  `stintID` int(11) DEFAULT NULL,
  `teamID` varchar(64) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `POS` varchar(64) DEFAULT NULL,
  `G` int(11) DEFAULT NULL,
  `GS` int(11) DEFAULT NULL,
  `InnOuts` int(11) DEFAULT NULL,
  `PO` int(11) DEFAULT NULL,
  `A` int(11) DEFAULT NULL,
  `E` int(11) DEFAULT NULL,
  `DP` int(11) DEFAULT NULL,
  `PB` varchar(64) DEFAULT NULL,
  `WP` varchar(64) DEFAULT NULL,
  `SB` varchar(64) DEFAULT NULL,
  `CS` varchar(64) DEFAULT NULL,
  `ZR` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`playerID`, `yearID`, `stintID`, `teamID`, `lgID`, `POS`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `FieldingPost`
-- ----------------------------
DROP TABLE IF EXISTS `FieldingPost`;
CREATE TABLE `FieldingPost` (
  `playerID` varchar(64) NOT NULL,
  `yearID` int(11) NOT NULL,
  `teamID` varchar(64) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `roundID` varchar(64) DEFAULT NULL,
  `POS` varchar(64) DEFAULT NULL,
  `G` int(11) DEFAULT NULL,
  `GS` int(11) DEFAULT NULL,
  `InnOuts` int(11) DEFAULT NULL,
  `PO` int(11) DEFAULT NULL,
  `A` int(11) DEFAULT NULL,
  `E` int(11) DEFAULT NULL,
  `DP` int(11) DEFAULT NULL,
  `TP` int(11) DEFAULT NULL,
  `PB` varchar(64) DEFAULT NULL,
  `SB` varchar(64) DEFAULT NULL,
  `CS` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`playerID`, `yearID`, `teamID`, `lgID`, `roundID`, `POS`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `HallOfFame`
-- ----------------------------
DROP TABLE IF EXISTS `HallOfFame`;
CREATE TABLE `HallOfFame` (
  `playerID` varchar(64) NOT NULL,
  `yearID` int(11) NOT NULL,
  `votedByID` varchar(64) DEFAULT NULL,
  `ballots` int(11) DEFAULT NULL,
  `needed` int(11) DEFAULT NULL,
  `votes` int(11) DEFAULT NULL,
  `inducted` varchar(64) DEFAULT NULL,
  `category` varchar(64) DEFAULT NULL,
  `needed_note` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`playerID`, `yearID`, `votedByID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `HomeGames`
-- ----------------------------
DROP TABLE IF EXISTS `HomeGames`;
CREATE TABLE `HomeGames` (
  `yearID` int(11) NOT NULL,
  `leagueID` varchar(64) NOT NULL,
  `teamID` varchar(64) NOT NULL,
  `parkID` varchar(64) NOT NULL,
  `span_first` varchar(64) DEFAULT NULL,
  `span_last` varchar(64) DEFAULT NULL,
  `games` int(11) DEFAULT NULL,
  `openings` int(11) DEFAULT NULL,
  `attendance` int(11) DEFAULT NULL,
  PRIMARY KEY(`yearID`, `leagueID`, `teamID`, `parkID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `Managers`
-- ----------------------------
DROP TABLE IF EXISTS `Managers`;
CREATE TABLE `Managers` (
  `playerID` varchar(64) NOT NULL,
  `yearID` int(11) NOT NULL,
  `teamID` varchar(64) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `inseasonID` int(11) DEFAULT NULL,
  `G` int(11) DEFAULT NULL,
  `W` int(11) DEFAULT NULL,
  `L` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `plyrMgr` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`playerID`, `yearID`, `teamID`, `lgID`, `inseasonID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `ManagersHalf`
-- ----------------------------
DROP TABLE IF EXISTS `ManagersHalf`;
CREATE TABLE `ManagersHalf` (
  `playerID` varchar(64) NOT NULL,
  `yearID` int(11) NOT NULL,
  `teamID` varchar(64) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `inseason` int(11) DEFAULT NULL,
  `halfID` int(11) DEFAULT NULL,
  `G` int(11) DEFAULT NULL,
  `W` int(11) DEFAULT NULL,
  `L` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  PRIMARY KEY(`playerID`, `yearID`, `teamID`, `lgID`, `halfID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `Player`
-- ----------------------------
DROP TABLE IF EXISTS `Player`;
CREATE TABLE `Player` (
  `playerID` varchar(64) NOT NULL,
  `birthYear` int(11) DEFAULT NULL,
  `birthMonth` int(11) DEFAULT NULL,
  `birthDay` int(11) DEFAULT NULL,
  `birthCountry` varchar(64) DEFAULT NULL,
  `birthState` varchar(64) DEFAULT NULL,
  `birthCity` varchar(64) DEFAULT NULL,
  `deathYear` varchar(64) DEFAULT NULL,
  `deathMonth` varchar(64) DEFAULT NULL,
  `deathDay` varchar(64) DEFAULT NULL,
  `deathCountry` varchar(64) DEFAULT NULL,
  `deathState` varchar(64) DEFAULT NULL,
  `deathCity` varchar(64) DEFAULT NULL,
  `nameFirst` varchar(64) DEFAULT NULL,
  `nameLast` varchar(64) DEFAULT NULL,
  `nameGiven` varchar(64) DEFAULT NULL,
  `weight` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `bats` varchar(64) DEFAULT NULL,
  `throws` varchar(64) DEFAULT NULL,
  `debut` varchar(64) DEFAULT NULL,
  `finalGame` varchar(64) DEFAULT NULL,
  `retroID` varchar(64) DEFAULT NULL,
  `bbrefID` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`playerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `Parks`
-- ----------------------------
DROP TABLE IF EXISTS `Parks`;
CREATE TABLE `Parks` (
  `parkID` varchar(64) NOT NULL,
  `park_name` varchar(64) DEFAULT NULL,
  `park_alias` varchar(64) DEFAULT NULL,
  `city` varchar(64) DEFAULT NULL,
  `state` varchar(64) DEFAULT NULL,
  `country` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`parkID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `Pitching`
-- ----------------------------
DROP TABLE IF EXISTS `Pitching`;
CREATE TABLE `Pitching` (
  `playerID` varchar(64) NOT NULL,
  `yearID` int(11) NOT NULL,
  `stintID` int(11) DEFAULT NULL,
  `teamID` varchar(64) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `W` int(11) DEFAULT NULL,
  `L` int(11) DEFAULT NULL,
  `G` int(11) DEFAULT NULL,
  `GS` int(11) DEFAULT NULL,
  `CG` int(11) DEFAULT NULL,
  `SHO` int(11) DEFAULT NULL,
  `SV` int(11) DEFAULT NULL,
  `IPouts` int(11) DEFAULT NULL,
  `H` int(11) DEFAULT NULL,
  `ER` int(11) DEFAULT NULL,
  `HR` int(11) DEFAULT NULL,
  `BB` int(11) DEFAULT NULL,
  `SO` int(11) DEFAULT NULL,
  `BAOpp` varchar(64) DEFAULT NULL,
  `ERA` float DEFAULT NULL,
  `IBB` varchar(64) DEFAULT NULL,
  `WP` varchar(64) DEFAULT NULL,
  `HBP` varchar(64) DEFAULT NULL,
  `BK` int(11) DEFAULT NULL,
  `BFP` varchar(64) DEFAULT NULL,
  `GF` varchar(64) DEFAULT NULL,
  `R` int(11) DEFAULT NULL,
  `SH` varchar(64) DEFAULT NULL,
  `SF` varchar(64) DEFAULT NULL,
  `GIDP` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`playerID`, `yearID`, `stintID`, `teamID`, `lgID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `PitchingPost`
-- ----------------------------
DROP TABLE IF EXISTS `PitchingPost`;
CREATE TABLE `PitchingPost` (
  `playerID` varchar(64) NOT NULL,
  `yearID` int(11) NOT NULL,
  `roundID` varchar(64) DEFAULT NULL,
  `teamID` varchar(64) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `W` int(11) DEFAULT NULL,
  `L` int(11) DEFAULT NULL,
  `G` int(11) DEFAULT NULL,
  `GS` int(11) DEFAULT NULL,
  `CG` int(11) DEFAULT NULL,
  `SHO` int(11) DEFAULT NULL,
  `SV` int(11) DEFAULT NULL,
  `IPouts` int(11) DEFAULT NULL,
  `H` int(11) DEFAULT NULL,
  `ER` int(11) DEFAULT NULL,
  `HR` int(11) DEFAULT NULL,
  `BB` int(11) DEFAULT NULL,
  `SO` int(11) DEFAULT NULL,
  `BAOpp` float DEFAULT NULL,
  `ERA` varchar(64) DEFAULT NULL,
  `IBB` int(11) DEFAULT NULL,
  `WP` int(11) DEFAULT NULL,
  `HBP` int(11) DEFAULT NULL,
  `BK` int(11) DEFAULT NULL,
  `BFP` int(11) DEFAULT NULL,
  `GF` int(11) DEFAULT NULL,
  `R` int(11) DEFAULT NULL,
  `SH` int(11) DEFAULT NULL,
  `SF` int(11) DEFAULT NULL,
  `GIDP` int(11) DEFAULT NULL,
  PRIMARY KEY(`playerID`, `yearID`, `roundID`, `teamID`, `lgID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `Salaries`
-- ----------------------------
DROP TABLE IF EXISTS `Salaries`;
CREATE TABLE `Salaries` (
  `yearID` int(11) NOT NULL,
  `teamID` varchar(64) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `playerID` varchar(64) NOT NULL,
  `salary` int(11) DEFAULT NULL,
  PRIMARY KEY(`yearID`, `teamID`, `lgID`, `playerID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `Schools`
-- ----------------------------
DROP TABLE IF EXISTS `Schools`;
CREATE TABLE `Schools` (
  `schoolID` varchar(64) NOT NULL,
  `name_full` varchar(64) DEFAULT NULL,
  `city` varchar(64) DEFAULT NULL,
  `state` varchar(64) DEFAULT NULL,
  `country` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`schoolID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `SeriesPost`
-- ----------------------------
DROP TABLE IF EXISTS `SeriesPost`;
CREATE TABLE `SeriesPost` (
  `yearID` int(11) NOT NULL,
  `roundID` varchar(64) DEFAULT NULL,
  `winnerID` varchar(64) DEFAULT NULL,
  `lgIDwinner` varchar(64) DEFAULT NULL,
  `loserID` varchar(64) DEFAULT NULL,
  `lgIDloser` varchar(64) DEFAULT NULL,
  `wins` int(11) DEFAULT NULL,
  `losses` int(11) DEFAULT NULL,
  `ties` int(11) DEFAULT NULL,
  PRIMARY KEY(`yearID`, `roundID`, `winnerID`, `loserid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `Teams`
-- ----------------------------
DROP TABLE IF EXISTS `Teams`;
CREATE TABLE `Teams` (
  `yearID` int(11) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `teamID` varchar(64) NOT NULL,
  `franchID` varchar(64) NOT NULL,
  `divID` varchar(64) NOT NULL,
  `Rank` int(11) DEFAULT NULL,
  `G` int(11) DEFAULT NULL,
  `Ghome` varchar(64) DEFAULT NULL,
  `W` int(11) DEFAULT NULL,
  `L` int(11) DEFAULT NULL,
  `DivWin` varchar(64) DEFAULT NULL,
  `WCWin` varchar(64) DEFAULT NULL,
  `LgWin` varchar(64) DEFAULT NULL,
  `WSWin` varchar(64) DEFAULT NULL,
  `R` int(11) DEFAULT NULL,
  `AB` int(11) DEFAULT NULL,
  `H` int(11) DEFAULT NULL,
  `2B` int(11) DEFAULT NULL,
  `3B` int(11) DEFAULT NULL,
  `HR` int(11) DEFAULT NULL,
  `BB` int(11) DEFAULT NULL,
  `SO` int(11) DEFAULT NULL,
  `SB` int(11) DEFAULT NULL,
  `CS` varchar(64) DEFAULT NULL,
  `HBP` varchar(64) DEFAULT NULL,
  `SF` varchar(64) DEFAULT NULL,
  `RA` int(11) DEFAULT NULL,
  `ER` int(11) DEFAULT NULL,
  `ERA` float DEFAULT NULL,
  `CG` int(11) DEFAULT NULL,
  `SHO` int(11) DEFAULT NULL,
  `SV` int(11) DEFAULT NULL,
  `IPouts` int(11) DEFAULT NULL,
  `HA` int(11) DEFAULT NULL,
  `HRA` int(11) DEFAULT NULL,
  `BBA` int(11) DEFAULT NULL,
  `SOA` int(11) DEFAULT NULL,
  `E` int(11) DEFAULT NULL,
  `DP` varchar(64) DEFAULT NULL,
  `FP` float DEFAULT NULL,
  `name` varchar(64) DEFAULT NULL,
  `park` varchar(64) DEFAULT NULL,
  `attendance` varchar(64) DEFAULT NULL,
  `BPF` int(11) DEFAULT NULL,
  `PPF` int(11) DEFAULT NULL,
  `teamIDBR` varchar(64) DEFAULT NULL,
  `teamIDlahman45` varchar(64) DEFAULT NULL,
  `teamIDretro` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`yearID`, `lgID`, `teamID`, `franchID`, `divID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `TeamsFranchises`
-- ----------------------------
DROP TABLE IF EXISTS `TeamsFranchises`;
CREATE TABLE `TeamsFranchises` (
  `franchID` varchar(64) NOT NULL,
  `franchName` varchar(64) DEFAULT NULL,
  `active` varchar(64) DEFAULT NULL,
  `NAassoc` varchar(64) DEFAULT NULL,
  PRIMARY KEY(`franchID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
--  Table structure for `TeamsHalf`
-- ----------------------------
DROP TABLE IF EXISTS `TeamsHalf`;
CREATE TABLE `TeamsHalf` (
  `yearID` int(11) NOT NULL,
  `lgID` varchar(64) NOT NULL,
  `teamID` varchar(64) NOT NULL,
  `HalfID` int(11) DEFAULT NULL,
  `divID` varchar(64) NOT NULL,
  `DivWin` varchar(64) DEFAULT NULL,
  `Rank` int(11) DEFAULT NULL,
  `G` int(11) DEFAULT NULL,
  `W` int(11) DEFAULT NULL,
  `L` int(11) DEFAULT NULL,
  PRIMARY KEY(`yearID`, `lgID`, `teamID`, `HalfID`, `divID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

