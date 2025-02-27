-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 06, 2025 at 08:21 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `dblokal`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `hapusDOSEN` (IN `pid_dosen` VARCHAR(16))   BEGIN
	DELETE FROM t_persons
    where id = (SELECT id_persons from t_dosen where id_dosen = pid_dosen);
	delete from t_dosen
	where id_dosen = pid_dosen;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `hapusMHS` (IN `pnim` VARCHAR(20))   BEGIN
    DECLARE pid_persons INT;

    -- Periksa apakah mahasiswa dengan NIM ada di tabel t_mhs
    IF NOT EXISTS (SELECT 1 FROM t_mhs WHERE nim = pnim) THEN
        -- Jika tidak ada, kirimkan pesan error
        SELECT 'ERROR' AS rstatus, 'Mahasiswa dengan NIM tidak ditemukan' AS rpesan;
    ELSE
        -- Ambil id_persons berdasarkan nim
        SELECT id_persons INTO pid_persons FROM t_mhs WHERE nim = pnim;

        -- Hapus data mahasiswa di t_mhs
        DELETE FROM t_mhs WHERE nim = pnim;

        -- Hapus data pribadi mahasiswa di t_persons
        DELETE FROM t_persons WHERE id = pid_persons;

        -- Mengembalikan hasil jika sukses
        SELECT 'SUKSES' AS rstatus, 'Data mahasiswa berhasil dihapus' AS rpesan;
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sisipDOSEN` (IN `pid_dosen` VARCHAR(16), IN `pnama` VARCHAR(255), IN `ptempat_lahir` VARCHAR(255), IN `ptanggal_lahir` DATE, IN `pjenis_kelamin` VARCHAR(255), IN `pmasuk` DATE, IN `pkeluar` DATE)   BEGIN
	#Routine body goes here...
	
	INSERT INTO t_dosen (id_dosen,id_persons) VALUES (`pid_dosen`, insertPerson(`pnama`, `ptempat_lahir`, `ptanggal_lahir`, `pjenis_kelamin`, `pmasuk`, `pkeluar`));
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sisipMHS` (IN `pnim` VARCHAR(16), IN `pnama` VARCHAR(255), IN `ptempat_lahir` VARCHAR(255), IN `ptanggal_lahir` DATE, IN `pjenis_kelamin` VARCHAR(1), IN `pmasuk` DATE, IN `pkeluar` DATE)   BEGIN
    DECLARE pid_persons INT;

    -- Insert data ke t_persons
    INSERT INTO t_persons (nama, tempat_lahir, tanggal_lahir, jenis_kelamin, masuk, keluar)
    VALUES (pnama, ptempat_lahir, ptanggal_lahir, pjenis_kelamin, pmasuk, pkeluar);
    
    -- Ambil ID terakhir dari tabel t_persons
    SET pid_persons = LAST_INSERT_ID();
    
    -- Insert data ke t_mhs
    INSERT INTO t_mhs (nim, id_persons) 
    VALUES (pnim, pid_persons);
    
    SELECT 'SUKSES' AS rstatus, 'Data mahasiswa berhasil ditambahkan' AS rpesan;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `tampilDOSEN` (IN `filter` INT)   select * from v_dosen$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `tampilMHS` (IN `filter` INT)   BEGIN
    -- Menampilkan data mahasiswa berdasarkan filter (contoh: filter 1 untuk semua mahasiswa, filter 2 untuk mahasiswa tertentu)
    IF filter = 1 THEN
        SELECT * FROM v_mhs;
    ELSE
        -- Menampilkan data mahasiswa berdasarkan kondisi filter tertentu
        SELECT * FROM v_mhs WHERE nim = filter;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ubahDOSEN` (IN `poldid_dosen` VARCHAR(16), IN `pid_dosen` VARCHAR(16), IN `pnama` VARCHAR(255), IN `ptempat_lahir` VARCHAR(255), IN `ptanggal_lahir` DATE, IN `pjenis_kelamin` VARCHAR(255), IN `pmasuk` DATE, IN `pkeluar` DATE)   BEGIN
    DECLARE jml INTEGER;

    SELECT COUNT(*) INTO jml FROM t_dosen WHERE id_dosen = pid_dosen;
    
    IF jml = 0 or pid_dosen = poldid_dosen THEN
        UPDATE t_dosen SET id_dosen = pid_dosen WHERE id_dosen = poldid_dosen;
        
        UPDATE t_persons SET
            nama = pnama,
            jenis_kelamin = pjenis_kelamin,
            tempat_lahir = ptempat_lahir,
            tanggal_lahir = ptanggal_lahir,
            masuk = pmasuk,
            keluar = pkeluar
        WHERE id = (SELECT id_persons FROM t_dosen WHERE id_dosen = pid_dosen);
        
        SELECT 'SUKSES' AS rstatus, 'Data sudah di ubah' AS rpesan;
				select * from v_dosen;
    ELSE
        SELECT 'ERROR' AS rstatus, 'ID DOSEN sudah digunakan' AS rpesan;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ubahMHS` (IN `poldnim` VARCHAR(16), IN `pnim` VARCHAR(16), IN `pnama` VARCHAR(255), IN `ptempat_lahir` VARCHAR(255), IN `ptanggal_lahir` DATE, IN `pjenis_kelamin` VARCHAR(1), IN `pmasuk` DATE, IN `pkeluar` DATE)   BEGIN
    DECLARE jml INTEGER;

    -- Cek apakah nim baru sudah ada atau belum
    SELECT COUNT(*) INTO jml FROM t_mhs WHERE nim = pnim;

    IF jml = 0 OR poldnim = pnim THEN
        -- Update data mahasiswa di t_persons
        UPDATE t_persons SET
            nama = pnama,
            tempat_lahir = ptempat_lahir,
            tanggal_lahir = ptanggal_lahir,
            jenis_kelamin = pjenis_kelamin,
            masuk = pmasuk,
            keluar = pkeluar
        WHERE id = (SELECT id_persons FROM t_mhs WHERE nim = poldnim);

        -- Update nim di t_mhs
        UPDATE t_mhs SET nim = pnim WHERE nim = poldnim;
        
        SELECT 'SUKSES' AS rstatus, 'Data mahasiswa berhasil diubah' AS rpesan;
    ELSE
        SELECT 'ERROR' AS rstatus, 'NIM sudah digunakan' AS rpesan;
    END IF;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `insertPerson` (`pnama` VARCHAR(255), `ptempat_lahir` VARCHAR(255), `ptanggal_lahir` DATE, `pjenis_kelamin` VARCHAR(1), `pmasuk` DATE, `pkeluar` DATE) RETURNS INT(11)  BEGIN
INSERT INTO t_persons (nama,tempat_lahir, tanggal_lahir, jenis_kelamin, masuk, keluar) VALUES (`pnama`, `ptempat_lahir`, `ptanggal_lahir`, `pjenis_kelamin`, `pmasuk`, `pkeluar`);
return LAST_INSERT_ID();
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `t_ampu`
--

CREATE TABLE `t_ampu` (
  `id` int(11) NOT NULL,
  `id_dosen` varchar(16) NOT NULL,
  `id_matakuliah` varchar(16) NOT NULL,
  `periode` varchar(9) DEFAULT NULL,
  `semester` varchar(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `t_ampu`
--

INSERT INTO `t_ampu` (`id`, `id_dosen`, `id_matakuliah`, `periode`, `semester`) VALUES
(1, 'DSN01', 'MK01', '2024/2025', 'PENDEK');

-- --------------------------------------------------------

--
-- Table structure for table `t_dosen`
--

CREATE TABLE `t_dosen` (
  `id_dosen` varchar(16) NOT NULL,
  `id_persons` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `t_dosen`
--

INSERT INTO `t_dosen` (`id_dosen`, `id_persons`) VALUES
('DSN01', 1),
('DSN02', 14),
('DSN03', 16),
('DSN88', 20);

-- --------------------------------------------------------

--
-- Table structure for table `t_krs`
--

CREATE TABLE `t_krs` (
  `id` int(11) NOT NULL,
  `tanggal` date DEFAULT NULL,
  `nim` varchar(16) DEFAULT NULL,
  `semester` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `t_krs`
--

INSERT INTO `t_krs` (`id`, `tanggal`, `nim`, `semester`) VALUES
(1, '2024-07-27', 'MH01', 2),
(2, '2024-07-27', 'MH02', 2),
(3, '2024-07-27', 'MH03', 2),
(4, '2024-07-27', 'MH04', 2),
(5, '2024-07-27', 'MH05', 2);

-- --------------------------------------------------------

--
-- Table structure for table `t_krs_detail`
--

CREATE TABLE `t_krs_detail` (
  `id` int(11) NOT NULL,
  `id_krs` int(11) NOT NULL,
  `id_matakuliah` varchar(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `t_krs_detail`
--

INSERT INTO `t_krs_detail` (`id`, `id_krs`, `id_matakuliah`) VALUES
(1, 1, 'MK01'),
(2, 1, 'MK02'),
(3, 1, 'MK03'),
(4, 2, 'MK01'),
(5, 3, 'MK01'),
(6, 3, 'MK03'),
(7, 4, 'MK02'),
(8, 5, 'MK03');

-- --------------------------------------------------------

--
-- Table structure for table `t_log`
--

CREATE TABLE `t_log` (
  `id` int(11) NOT NULL,
  `tanggal` date DEFAULT current_timestamp(),
  `keterangan` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `t_log`
--

INSERT INTO `t_log` (`id`, `tanggal`, `keterangan`) VALUES
(1, '2024-07-27', 'Fahrul Riyad menjadi Fahrul Riyadi'),
(2, '2024-08-10', 'test'),
(4, '2024-08-10', 'Test Dosen'),
(5, '2024-08-10', 'Test Dosen menjadi Ultramen'),
(6, '2024-08-24', 'test'),
(7, '2024-08-24', 'test'),
(8, '2024-08-24', 'test'),
(9, '2024-08-24', 'test'),
(10, '2024-08-27', 'test'),
(11, '2024-08-27', 'test menjadi test ubah'),
(12, '2024-08-27', 'test ubah menjadi test ubah 01'),
(13, '2024-08-27', 'test ubah 01 menjadi test ubah 01'),
(14, '2024-08-27', 'test ubah 01 menjadi test ubah 01'),
(15, '2024-08-27', 'test ubah 01 menjadi test ubah 01'),
(16, '2024-08-27', 'test'),
(17, '2024-08-27', 'test menjadi test ubah 01'),
(18, '2024-09-04', 'test'),
(19, '2024-09-04', 'test'),
(20, '2024-09-04', 'test'),
(21, '2024-09-04', 'test menjadi test VB'),
(22, '2024-09-04', 'M. Ramadhan menjadi M. Ramadhan'),
(23, '2024-09-04', 'Donni Setiawan menjadi Donni Setiawan'),
(24, '2024-09-04', 'Azni Hana Pratiwi menjadi Azni Hana Pratiwi'),
(25, '2024-09-04', 'Azni Hana Pratiwi menjadi Azni Hana Pratiwi'),
(26, '2024-09-04', 'Dinda Tarwiyah menjadi Dinda Tarwiyah'),
(27, '2024-09-04', 'Ahmad Umar menjadi Ahmad Umar'),
(28, '2024-09-04', 'Suci Aura Puspitasari menjadi Suci Aura Puspitasari'),
(29, '2024-09-04', 'Fahrul Riyadi menjadi Fahrul Riyadi'),
(30, '2024-09-04', 'test VB menjadi test VB kk'),
(31, '2024-09-04', 'test VB kk menjadi test VB kk'),
(32, '2024-09-04', 'test VB kk menjadi test VB kk'),
(33, '2024-09-04', 'test VB kk menjadi test VB kk'),
(34, '2024-09-04', 'test VB kk menjadi test VB kk'),
(35, '2024-09-04', 'test VB kk menjadi test VB kk'),
(36, '2024-09-05', 'test VB kk menjadi test VB kk'),
(37, '2024-09-05', 'test'),
(38, '2024-09-05', 'Mahasiswa 77'),
(39, '2024-09-05', 'Mahasiswa 77 menjadi Mahasiswa 77'),
(40, '2024-09-05', 'test menjadi Mahasiswa Test'),
(41, '2024-09-07', 'Mahasiswa 77 menjadi Mahasiswa 77'),
(42, '2024-09-07', 'Mahasiswa Test menjadi Mahasiswa Test'),
(43, '2024-09-07', 'Mahasiswa Test menjadi Mahasiswa Test'),
(44, '2024-09-07', 'Mahasiswa Test menjadi Mahasiswa Test'),
(45, '2025-01-30', 'test'),
(46, '2025-01-30', 'test menjadi EAI'),
(47, '2025-02-06', 'Budi Santoso'),
(48, '2025-02-06', 'Budi Santoso'),
(49, '2025-02-06', 'Budi Santoso'),
(50, '2025-02-06', 'Budi Santoso');

-- --------------------------------------------------------

--
-- Table structure for table `t_matakuliah`
--

CREATE TABLE `t_matakuliah` (
  `id_matakuliah` varchar(16) NOT NULL,
  `nama_matakuliah` varchar(255) DEFAULT NULL,
  `sks` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `t_matakuliah`
--

INSERT INTO `t_matakuliah` (`id_matakuliah`, `nama_matakuliah`, `sks`) VALUES
('MK01', 'Bahasa Pemrograman', 3),
('MK02', 'Keamanan', 3),
('MK03', 'Web Programing', 3);

-- --------------------------------------------------------

--
-- Table structure for table `t_mhs`
--

CREATE TABLE `t_mhs` (
  `nim` varchar(16) NOT NULL,
  `id_persons` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `t_mhs`
--

INSERT INTO `t_mhs` (`nim`, `id_persons`) VALUES
('MH05', 6),
('MH06', 7),
('MH07', 8),
('MH77', 27),
('MH88', 26);

-- --------------------------------------------------------

--
-- Table structure for table `t_persons`
--

CREATE TABLE `t_persons` (
  `id` int(11) NOT NULL,
  `nama` varchar(255) DEFAULT NULL,
  `tempat_lahir` varchar(255) DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `jenis_kelamin` varchar(1) DEFAULT NULL,
  `masuk` date DEFAULT NULL,
  `keluar` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;

--
-- Dumping data for table `t_persons`
--

INSERT INTO `t_persons` (`id`, `nama`, `tempat_lahir`, `tanggal_lahir`, `jenis_kelamin`, `masuk`, `keluar`) VALUES
(1, 'Farhan Zayid, ST., M.Kom.', 'Bekasi', '2024-06-01', 'L', '2024-05-01', NULL),
(6, 'Azni Hana Pratiwi', 'Sukabumi', '2024-07-26', 'P', '2024-05-01', '0000-00-00'),
(7, 'Donni Setiawan', 'Bogor', '2024-07-27', 'L', '2024-07-27', '0000-00-00'),
(8, 'M. Ramadhan', 'Sukabumi', '2024-07-27', 'L', '2024-07-27', '0000-00-00'),
(14, 'test', 'Bogor', '1980-01-27', 'L', '1980-01-27', '0000-00-00'),
(16, 'Ultramen', 'Test', '1980-01-27', 'L', '1980-01-27', '0000-00-00'),
(20, 'EAI', 'EAI', '2024-08-24', 'L', '2024-08-24', '0000-00-00'),
(21, 'test ubah 01', 'test', '2024-08-24', 'L', '2024-08-24', '0000-00-00'),
(22, 'test ubah 01', 'test', '2024-08-24', 'L', '2024-08-24', '0000-00-00'),
(23, 'test', 'test', '2024-08-24', 'L', '2024-08-24', '0000-00-00'),
(24, 'test', 'test', '2024-08-24', 'L', '2024-08-24', '0000-00-00'),
(25, 'test VB kk', 'Bekasi', '2024-08-24', 'L', '2024-08-24', '0000-00-00'),
(26, 'Mahasiswa Test', 'test', '2020-02-01', 'L', '2024-08-24', '0000-00-00'),
(27, 'Mahasiswa 77', 'Tempat Lahir', '2024-09-05', 'L', '2024-09-05', '0000-00-00'),
(30, 'Budi Santoso', 'Jakarta', '0000-00-00', 'L', '2024-02-01', '2028-01-31'),
(31, 'Budi Santoso', 'Jakarta', '2000-05-15', 'L', '2024-02-01', '2028-01-31'),
(32, 'Budi Santoso', 'Jakarta', '2000-05-15', 'L', '2024-02-01', '2028-01-31');

--
-- Triggers `t_persons`
--
DELIMITER $$
CREATE TRIGGER `jikaInsert` AFTER INSERT ON `t_persons` FOR EACH ROW INSERT INTO t_log (keterangan) VALUES (new.nama)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `jikaUpdate` AFTER UPDATE ON `t_persons` FOR EACH ROW INSERT INTO t_log (keterangan) VALUES ( CONCAT(old.nama, ' menjadi ', new.nama))
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_ampu`
-- (See below for the actual view)
--
CREATE TABLE `v_ampu` (
`id_ampu` int(11)
,`id_dosen` varchar(16)
,`masuk` date
,`keluar` date
,`nama` varchar(255)
,`jenis_kelamin` varchar(1)
,`tempat_lahir` varchar(255)
,`tanggal_lahir` date
,`id_matakuliah` varchar(16)
,`nama_matakuliah` varchar(255)
,`sks` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_dosen`
-- (See below for the actual view)
--
CREATE TABLE `v_dosen` (
`id_dosen` varchar(16)
,`id_persons` int(11)
,`id` int(11)
,`nama` varchar(255)
,`tempat_lahir` varchar(255)
,`tanggal_lahir` date
,`jenis_kelamin` varchar(1)
,`masuk` date
,`keluar` date
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_krs`
-- (See below for the actual view)
--
CREATE TABLE `v_krs` (
`id_krs` int(11)
,`nim` varchar(16)
,`semester` int(11)
,`tanggal` date
,`masuk` date
,`keluar` date
,`id_persons` int(11)
,`jenis_kelamin` varchar(1)
,`nama` varchar(255)
,`tempat_lahir` varchar(255)
,`tanggal_lahir` date
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_krs_detail`
-- (See below for the actual view)
--
CREATE TABLE `v_krs_detail` (
`id_detail` int(11)
,`id_krs` int(11)
,`id_matakuliah` varchar(16)
,`nama_matakuliah` varchar(255)
,`sks` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_mhs`
-- (See below for the actual view)
--
CREATE TABLE `v_mhs` (
`nim` varchar(16)
,`id_persons` int(11)
,`id` int(11)
,`nama` varchar(255)
,`tempat_lahir` varchar(255)
,`tanggal_lahir` date
,`jenis_kelamin` varchar(1)
,`masuk` date
,`keluar` date
);

-- --------------------------------------------------------

--
-- Structure for view `v_ampu`
--
DROP TABLE IF EXISTS `v_ampu`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_ampu`  AS SELECT `a`.`id` AS `id_ampu`, `a`.`id_dosen` AS `id_dosen`, `d`.`masuk` AS `masuk`, `d`.`keluar` AS `keluar`, `d`.`nama` AS `nama`, `d`.`jenis_kelamin` AS `jenis_kelamin`, `d`.`tempat_lahir` AS `tempat_lahir`, `d`.`tanggal_lahir` AS `tanggal_lahir`, `a`.`id_matakuliah` AS `id_matakuliah`, `mk`.`nama_matakuliah` AS `nama_matakuliah`, `mk`.`sks` AS `sks` FROM ((`t_ampu` `a` left join `t_matakuliah` `mk` on(`a`.`id_matakuliah` = `mk`.`id_matakuliah`)) left join `v_dosen` `d` on(`a`.`id_dosen` = `d`.`id_dosen`)) ;

-- --------------------------------------------------------

--
-- Structure for view `v_dosen`
--
DROP TABLE IF EXISTS `v_dosen`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_dosen`  AS SELECT `d`.`id_dosen` AS `id_dosen`, `d`.`id_persons` AS `id_persons`, `p`.`id` AS `id`, `p`.`nama` AS `nama`, `p`.`tempat_lahir` AS `tempat_lahir`, `p`.`tanggal_lahir` AS `tanggal_lahir`, `p`.`jenis_kelamin` AS `jenis_kelamin`, `p`.`masuk` AS `masuk`, `p`.`keluar` AS `keluar` FROM (`t_dosen` `d` left join `t_persons` `p` on(`d`.`id_persons` = `p`.`id`)) ;

-- --------------------------------------------------------

--
-- Structure for view `v_krs`
--
DROP TABLE IF EXISTS `v_krs`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_krs`  AS SELECT `k`.`id` AS `id_krs`, `k`.`nim` AS `nim`, `k`.`semester` AS `semester`, `k`.`tanggal` AS `tanggal`, `m`.`masuk` AS `masuk`, `m`.`keluar` AS `keluar`, `m`.`id_persons` AS `id_persons`, `m`.`jenis_kelamin` AS `jenis_kelamin`, `m`.`nama` AS `nama`, `m`.`tempat_lahir` AS `tempat_lahir`, `m`.`tanggal_lahir` AS `tanggal_lahir` FROM (`t_krs` `k` left join `v_mhs` `m` on(`k`.`nim` = `m`.`nim`)) ;

-- --------------------------------------------------------

--
-- Structure for view `v_krs_detail`
--
DROP TABLE IF EXISTS `v_krs_detail`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_krs_detail`  AS SELECT `kd`.`id` AS `id_detail`, `kd`.`id_krs` AS `id_krs`, `kd`.`id_matakuliah` AS `id_matakuliah`, `mk`.`nama_matakuliah` AS `nama_matakuliah`, `mk`.`sks` AS `sks` FROM (`t_krs_detail` `kd` left join `t_matakuliah` `mk` on(`kd`.`id_matakuliah` = `mk`.`id_matakuliah`)) ;

-- --------------------------------------------------------

--
-- Structure for view `v_mhs`
--
DROP TABLE IF EXISTS `v_mhs`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_mhs`  AS SELECT `m`.`nim` AS `nim`, `m`.`id_persons` AS `id_persons`, `p`.`id` AS `id`, `p`.`nama` AS `nama`, `p`.`tempat_lahir` AS `tempat_lahir`, `p`.`tanggal_lahir` AS `tanggal_lahir`, `p`.`jenis_kelamin` AS `jenis_kelamin`, `p`.`masuk` AS `masuk`, `p`.`keluar` AS `keluar` FROM (`t_mhs` `m` left join `t_persons` `p` on(`m`.`id_persons` = `p`.`id`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `t_ampu`
--
ALTER TABLE `t_ampu`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `t_dosen`
--
ALTER TABLE `t_dosen`
  ADD PRIMARY KEY (`id_dosen`) USING BTREE;

--
-- Indexes for table `t_krs`
--
ALTER TABLE `t_krs`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `t_krs_detail`
--
ALTER TABLE `t_krs_detail`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `t_log`
--
ALTER TABLE `t_log`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- Indexes for table `t_matakuliah`
--
ALTER TABLE `t_matakuliah`
  ADD PRIMARY KEY (`id_matakuliah`) USING BTREE;

--
-- Indexes for table `t_mhs`
--
ALTER TABLE `t_mhs`
  ADD PRIMARY KEY (`nim`) USING BTREE;

--
-- Indexes for table `t_persons`
--
ALTER TABLE `t_persons`
  ADD PRIMARY KEY (`id`) USING BTREE;

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `t_ampu`
--
ALTER TABLE `t_ampu`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `t_krs`
--
ALTER TABLE `t_krs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `t_krs_detail`
--
ALTER TABLE `t_krs_detail`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `t_log`
--
ALTER TABLE `t_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=51;

--
-- AUTO_INCREMENT for table `t_persons`
--
ALTER TABLE `t_persons`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
