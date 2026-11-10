-- MySQL dump 10.13  Distrib 8.0.46, for Linux (x86_64)
--
-- Host: localhost    Database: normalization_task
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
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `customer_id` int NOT NULL,
  `customer_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (12,'Дания'),(23,'Испания'),(25,'Албания');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `product_id` int NOT NULL,
  `product_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(10,2) NOT NULL,
  PRIMARY KEY (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (101,'Дыни',800.00),(102,'Клубника',150.00),(103,'Яблоки',120.00),(104,'Лимоны',200.00);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_items`
--

DROP TABLE IF EXISTS `report_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_items` (
  `report_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL,
  PRIMARY KEY (`report_id`,`product_id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `report_items_ibfk_1` FOREIGN KEY (`report_id`) REFERENCES `reports` (`report_id`),
  CONSTRAINT `report_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_items`
--

LOCK TABLES `report_items` WRITE;
/*!40000 ALTER TABLE `report_items` DISABLE KEYS */;
INSERT INTO `report_items` VALUES (1101,101,1100),(1101,102,300),(1102,103,1700),(1103,104,500),(1104,101,2500),(1105,103,2000),(1105,104,700);
/*!40000 ALTER TABLE `report_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports`
--

DROP TABLE IF EXISTS `reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reports` (
  `report_id` int NOT NULL,
  `report_date` date NOT NULL,
  `customer_id` int NOT NULL,
  PRIMARY KEY (`report_id`),
  KEY `customer_id` (`customer_id`),
  CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports`
--

LOCK TABLES `reports` WRITE;
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
INSERT INTO `reports` VALUES (1101,'2026-03-05',12),(1102,'2026-03-07',23),(1103,'2026-03-08',25),(1104,'2026-03-10',12),(1105,'2026-03-12',25);
/*!40000 ALTER TABLE `reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sales_unnormalized_2`
--

DROP TABLE IF EXISTS `sales_unnormalized_2`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sales_unnormalized_2` (
  `report_id` int DEFAULT NULL,
  `report_date` date DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `customer_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `product_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `quantity` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales_unnormalized_2`
--

LOCK TABLES `sales_unnormalized_2` WRITE;
/*!40000 ALTER TABLE `sales_unnormalized_2` DISABLE KEYS */;
INSERT INTO `sales_unnormalized_2` VALUES (1101,'2026-03-05',12,'Дания',101,'Дыни',800.00,1100),(1101,'2026-03-05',12,'Дания',102,'Клубника',150.00,300),(1102,'2026-03-07',23,'Испания',103,'Яблоки',120.00,1700),(1103,'2026-03-08',25,'Албания',104,'Лимоны',200.00,500),(1104,'2026-03-10',12,'Дания',101,'Дыни',800.00,2500),(1105,'2026-03-12',25,'Албания',103,'Яблоки',120.00,2000),(1105,'2026-03-12',25,'Албания',104,'Лимоны',200.00,700);
/*!40000 ALTER TABLE `sales_unnormalized_2` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sales_unnormalized_2_backup`
--

DROP TABLE IF EXISTS `sales_unnormalized_2_backup`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sales_unnormalized_2_backup` (
  `report_id` int DEFAULT NULL,
  `report_date` date DEFAULT NULL,
  `customer_id` int DEFAULT NULL,
  `customer_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_id` int DEFAULT NULL,
  `product_name` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `quantity` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales_unnormalized_2_backup`
--

LOCK TABLES `sales_unnormalized_2_backup` WRITE;
/*!40000 ALTER TABLE `sales_unnormalized_2_backup` DISABLE KEYS */;
INSERT INTO `sales_unnormalized_2_backup` VALUES (1101,'2026-03-05',12,'Дания',101,'Дыни',800.00,1100),(1101,'2026-03-05',12,'Дания',102,'Клубника',150.00,300),(1102,'2026-03-07',23,'Испания',103,'Яблоки',120.00,1700),(1103,'2026-03-08',25,'Албания',104,'Лимоны',200.00,500),(1104,'2026-03-10',12,'Дания',101,'Дыни',800.00,2500),(1105,'2026-03-12',25,'Албания',103,'Яблоки',120.00,2000),(1105,'2026-03-12',25,'Албания',104,'Лимоны',200.00,700);
/*!40000 ALTER TABLE `sales_unnormalized_2_backup` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-10  8:30:12
