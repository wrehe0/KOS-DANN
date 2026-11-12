-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: sales_norm
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `departments` (
  `department_id` int NOT NULL,
  `department_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments`
--

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
INSERT INTO `departments` VALUES (10,'Отдел реализации'),(20,'Отдел развития'),(30,'Отдел экспорта');
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee_sales`
--

DROP TABLE IF EXISTS `employee_sales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_sales` (
  `employee_id` int NOT NULL,
  `sale_month` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL,
  `department_id` int NOT NULL,
  `sales_amount` decimal(12,2) NOT NULL,
  PRIMARY KEY (`employee_id`,`sale_month`,`department_id`),
  KEY `department_id` (`department_id`),
  CONSTRAINT `employee_sales_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`),
  CONSTRAINT `employee_sales_ibfk_2` FOREIGN KEY (`department_id`) REFERENCES `departments` (`department_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_sales`
--

LOCK TABLES `employee_sales` WRITE;
/*!40000 ALTER TABLE `employee_sales` DISABLE KEYS */;
INSERT INTO `employee_sales` VALUES (1,'2026-01',10,120000.00),(1,'2026-01',20,80000.00),(1,'2026-01',30,50000.00),(1,'2026-02',10,130000.00),(1,'2026-02',20,85000.00),(2,'2026-01',10,150000.00),(2,'2026-01',30,60000.00),(2,'2026-02',10,160000.00),(3,'2026-01',20,90000.00),(3,'2026-01',30,70000.00);
/*!40000 ALTER TABLE `employee_sales` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employee_sales_bad_backup`
--

DROP TABLE IF EXISTS `employee_sales_bad_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employee_sales_bad_backup` (
  `employee_id` int DEFAULT NULL,
  `employee_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sale_month` varchar(7) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sales_amount` decimal(12,2) DEFAULT NULL,
  `department_id` int DEFAULT NULL,
  `department_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employee_sales_bad_backup`
--

LOCK TABLES `employee_sales_bad_backup` WRITE;
/*!40000 ALTER TABLE `employee_sales_bad_backup` DISABLE KEYS */;
INSERT INTO `employee_sales_bad_backup` VALUES (1,'Иванов Иван','2026-01',120000.00,10,'Отдел реализации'),(1,'Иванов Иван','2026-01',80000.00,20,'Отдел развития'),(1,'Иванов Иван','2026-01',50000.00,30,'Отдел экспорта'),(2,'Петрова Мария','2026-01',150000.00,10,'Отдел реализации'),(2,'Петрова Мария','2026-01',60000.00,30,'Отдел экспорта'),(3,'Сидоров Алексей','2026-01',90000.00,20,'Отдел развития'),(3,'Сидоров Алексей','2026-01',70000.00,30,'Отдел экспорта'),(1,'Иванов Иван','2026-02',130000.00,10,'Отдел реализации'),(1,'Иванов Иван','2026-02',85000.00,20,'Отдел развития'),(2,'Петрова Мария','2026-02',160000.00,10,'Отдел реализации');
/*!40000 ALTER TABLE `employee_sales_bad_backup` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `employees` (
  `employee_id` int NOT NULL,
  `employee_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`employee_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `employees`
--

LOCK TABLES `employees` WRITE;
/*!40000 ALTER TABLE `employees` DISABLE KEYS */;
INSERT INTO `employees` VALUES (1,'Иванов Иван'),(2,'Петрова Мария'),(3,'Сидоров Алексей');
/*!40000 ALTER TABLE `employees` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-12  7:44:28
