-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 27 Des 2023 pada 09.43
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `tubes_basdat`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetAvailableRooms` (IN `checkin_date` DATE, IN `checkout_date` DATE)   BEGIN
    SELECT k.id_kamar, k.no_kamar, k.jenis_kamar, k.harga_kamar
    FROM kamar k
    WHERE k.id_kamar NOT IN (
        SELECT r.id_kamar
        FROM reservasi r
        WHERE (checkin_date BETWEEN r.check_in AND r.check_out
            OR checkout_date BETWEEN r.check_in AND r.check_out
            OR r.check_in BETWEEN checkin_date AND checkout_date
            OR r.check_out BETWEEN checkin_date AND checkout_date)
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `inputReservasi` (IN `id_customer_param` INT, IN `id_kamar_param` INT, IN `id_addon_param` INT, IN `check_in_param` DATE, IN `check_out_param` DATE)   BEGIN
    DECLARE id_pekerja_value INT;
    
    SET id_pekerja_value = FLOOR(1 + (RAND() * 3));
    
    IF (SELECT status_kamar FROM kamar WHERE id_kamar = id_kamar_param) = 'Terisi' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Maaf kamar sudah di Booking';
    ELSE
        -- Tambahkan reservasi jika kamar belum di-booking
        INSERT INTO reservasi (
            id_customer,
            id_pekerja,
            id_kamar,
            id_addon,
            check_in,
            check_out
        ) VALUES (
            id_customer_param,
            id_pekerja_value,
            id_kamar_param,
            id_addon_param,
            check_in_param,
            check_out_param
        );
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `input_customer_baru` (IN `nama_customer` VARCHAR(255), IN `no_telp_customer` VARCHAR(255), IN `jenis_kelamin_customer` VARCHAR(255))   BEGIN
    INSERT INTO customer(nama, no_telp, jenis_kelamin)
    VALUES (nama_customer, no_telp_customer, jenis_kelamin_customer);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `tampilkan_total_harga` (IN `id_reservasi_param` INT)   BEGIN
    SELECT 
        c.nama AS nama_customer,
        k.jenis_kamar,
        k.harga_kamar,
        COALESCE(SUM(a.harga_add_on), 0) AS total_add_on,
        k.harga_kamar + COALESCE(SUM(a.harga_add_on), 0) AS total_harga
    FROM 
        customer c
    JOIN 
        reservasi r ON c.id_customer = r.id_customer
    JOIN 
        kamar k ON r.id_kamar = k.id_kamar
    LEFT JOIN 
        add_on a ON r.id_addon = a.id_add_on
    WHERE 
        r.id_reservasi = id_reservasi_param
    GROUP BY 
        c.nama, k.jenis_kamar, k.harga_kamar;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `add_on`
--

CREATE TABLE `add_on` (
  `id_add_on` int(11) NOT NULL,
  `nama_add_on` varchar(255) DEFAULT NULL,
  `harga_add_on` int(11) DEFAULT NULL,
  `id_pekerja` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `add_on`
--

INSERT INTO `add_on` (`id_add_on`, `nama_add_on`, `harga_add_on`, `id_pekerja`) VALUES
(1, 'Wifi', 50000, 1),
(2, 'Breakfast', 50000, 9),
(3, 'Spa Service', 100000, 4),
(4, 'vallet', 50000, 7),
(5, 'Gym Access', 80000, 3),
(6, 'Airport Shuttle', 120000, 8),
(7, 'Mini Bar', 60000, 3),
(8, 'Laundry Service', 90000, 5),
(9, 'Extra Pillow', 150000, 6),
(10, 'Room Service', 70000, 10);

-- --------------------------------------------------------

--
-- Struktur dari tabel `customer`
--

CREATE TABLE `customer` (
  `id_customer` int(11) NOT NULL,
  `nama` varchar(255) DEFAULT NULL,
  `no_telp` varchar(255) DEFAULT NULL,
  `jenis_kelamin` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `customer`
--

INSERT INTO `customer` (`id_customer`, `nama`, `no_telp`, `jenis_kelamin`) VALUES
(1, 'angela', '08123413880', 'p'),
(2, 'enji', '02111039200', 'p'),
(3, 'kayla', '2325856933', 'p'),
(4, 'windi', '1235698700', 'p'),
(5, 'aisyah', '5892369528', 'p'),
(6, 'asyam', '9632857421', 'L'),
(7, 'rengga', '3366995582', 'L'),
(8, 'rafael', '2111039620', 'L'),
(9, 'zidan', '2111032712', 'L'),
(10, 'lina', '1962582196', 'p'),
(11, 'beni', '1962196316', 'L'),
(12, 'niko', '2111039658', 'L'),
(13, 'sulis', '3692580132', 'p'),
(14, 'david', '2580369147', 'L'),
(15, 'lutpi', '3695280361', 'L'),
(16, 'uni', '2314569870', 'p'),
(17, 'dani', '2308199925', 'L'),
(18, 'tisa', '2111032065', 'p'),
(19, 'clarisa', '9632580741', 'p'),
(20, 'deren', '1256789034', 'L'),
(21, 'kurnia', '2119635874', 'L'),
(22, 'satya', '8756940231', 'L'),
(23, 'martin', '6669993325', 'L'),
(24, 'dharma', '8976452132', 'L'),
(25, 'lita', '3695802147', 'P'),
(26, 'dimas', '2111087963', 'L'),
(27, 'damar', '1319494673', 'L'),
(28, 'kumala', '1236579202', 'p'),
(29, 'anggun', '3636965823', 'p'),
(30, 'lala', '2187093456', 'p');

-- --------------------------------------------------------

--
-- Struktur dari tabel `kamar`
--

CREATE TABLE `kamar` (
  `id_kamar` int(11) NOT NULL,
  `no_kamar` int(11) DEFAULT NULL,
  `jenis_kamar` varchar(255) DEFAULT NULL,
  `harga_kamar` int(11) DEFAULT NULL,
  `status_kamar` enum('Terisi','Kosong') DEFAULT 'Kosong'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `kamar`
--

INSERT INTO `kamar` (`id_kamar`, `no_kamar`, `jenis_kamar`, `harga_kamar`, `status_kamar`) VALUES
(1, 101, 'Single', 100000, 'Terisi'),
(2, 102, 'Single', 100000, 'Kosong'),
(3, 103, 'Single', 100000, 'Kosong'),
(4, 104, 'Single', 100000, 'Kosong'),
(5, 105, 'Single', 100000, 'Kosong'),
(6, 201, 'Double', 250000, 'Kosong'),
(7, 202, 'Double', 250000, 'Kosong'),
(8, 203, 'Double', 250000, 'Kosong'),
(9, 204, 'Double', 250000, 'Kosong'),
(10, 205, 'Double', 250000, 'Kosong'),
(11, 301, 'Deluxe', 400000, 'Kosong'),
(12, 302, 'Deluxe', 400000, 'Kosong'),
(13, 303, 'Deluxe', 400000, 'Kosong'),
(14, 304, 'Deluxe', 400000, 'Kosong'),
(15, 305, 'Deluxe', 400000, 'Kosong');

-- --------------------------------------------------------

--
-- Struktur dari tabel `pegawai`
--

CREATE TABLE `pegawai` (
  `id_pekerja` int(11) NOT NULL,
  `nama_pekerja` varchar(255) DEFAULT NULL,
  `no_telp` int(11) DEFAULT NULL,
  `pekerjaan` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `pegawai`
--

INSERT INTO `pegawai` (`id_pekerja`, `nama_pekerja`, `no_telp`, `pekerjaan`) VALUES
(1, 'tita', 1789620867, 'Resepsionis'),
(2, 'ina', 2029362580, 'Resepsionis'),
(3, 'sinta', 2147483647, 'Resepsionis'),
(4, 'lulu', 2147483647, 'Spa Massager'),
(5, 'anggie', 2147483647, 'Cleaning Service'),
(6, 'frans', 2147483647, 'Cleaning Service'),
(7, 'ken', 2147483647, 'Satpam'),
(8, 'akbar', 1265870239, 'Driver'),
(9, 'subhan', 2147483647, 'Chef'),
(10, 'bagas', 1258462390, 'Manager');

-- --------------------------------------------------------

--
-- Struktur dari tabel `reservasi`
--

CREATE TABLE `reservasi` (
  `id_reservasi` int(11) NOT NULL,
  `id_customer` int(11) DEFAULT NULL,
  `id_pekerja` int(11) DEFAULT NULL,
  `id_kamar` int(11) DEFAULT NULL,
  `id_addon` int(11) DEFAULT NULL,
  `check_in` date DEFAULT NULL,
  `check_out` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `reservasi`
--

INSERT INTO `reservasi` (`id_reservasi`, `id_customer`, `id_pekerja`, `id_kamar`, `id_addon`, `check_in`, `check_out`) VALUES
(1, 1, 1, 1, 3, '2023-01-01', '2023-02-01'),
(2, 2, 3, 2, 6, '2023-01-05', '2023-02-05'),
(3, 3, 3, 3, 7, '2023-01-10', '2023-02-10'),
(4, 4, 1, 4, 9, '2023-01-15', '2023-02-15'),
(5, 5, 2, 5, 2, '2023-01-20', '2023-02-20'),
(6, 6, 2, 6, 4, '2023-01-25', '2023-02-25'),
(7, 7, 2, 7, 3, '2023-03-01', '2023-04-01'),
(8, 8, 1, 8, 4, '2023-03-05', '2023-04-05'),
(9, 9, 1, 9, 10, '2023-03-10', '2023-04-10'),
(10, 10, 3, 10, 5, '2023-03-15', '2023-04-15'),
(11, 11, 1, 11, 10, '2023-03-20', '2023-04-20'),
(12, 12, 2, 12, 5, '2023-03-25', '2023-04-25'),
(13, 13, 1, 13, 7, '2023-06-01', '2023-07-01'),
(14, 14, 1, 14, 10, '2023-06-05', '2023-07-05'),
(15, 15, 3, 15, 3, '2023-06-05', '2023-07-10'),
(16, 16, 2, 1, 9, '2023-06-10', '2023-07-15'),
(17, 17, 2, 2, 4, '2023-06-15', '2023-07-20'),
(18, 18, 3, 3, 6, '2023-06-20', '2023-07-25'),
(19, 19, 3, 4, 3, '2023-06-25', '2023-09-01'),
(20, 20, 2, 5, 8, '2023-08-01', '2023-09-05'),
(21, 21, 1, 6, 6, '2023-08-05', '2023-09-10'),
(22, 22, 3, 7, 3, '2023-08-10', '2023-09-15'),
(23, 23, 2, 8, 9, '2023-08-15', '2023-09-20'),
(24, 24, 1, 9, 2, '2023-08-20', '2023-09-25'),
(25, 25, 2, 10, 2, '2023-08-25', '2023-11-01'),
(26, 26, 3, 11, 1, '2023-10-01', '2023-11-05'),
(27, 27, 1, 12, 5, '2023-10-05', '2023-11-10'),
(28, 28, 1, 13, 10, '2023-10-10', '2023-11-15'),
(29, 29, 2, 14, 9, '2023-10-15', '2023-11-20'),
(30, 30, 1, 15, 6, '2023-10-20', '2023-11-25'),
(31, 1, 2, 1, 3, '2023-12-24', '2023-12-25'),
(32, 2, 3, 3, 3, '2023-12-25', '2023-12-26'),
(33, 1, 3, 1, 3, '2023-12-27', '2024-02-01'),
(34, 2, 3, 2, 6, '2024-03-05', '2024-04-05');

--
-- Trigger `reservasi`
--
DELIMITER $$
CREATE TRIGGER `set_kamar_terisi` AFTER INSERT ON `reservasi` FOR EACH ROW BEGIN
    DECLARE today DATE;
    SET today = CURRENT_DATE;

    IF (today BETWEEN NEW.check_in AND NEW.check_out) THEN
        UPDATE kamar
        SET status_kamar = 'Terisi'
        WHERE id_kamar = NEW.id_kamar;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `reservasi_belum_berjalan`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `reservasi_belum_berjalan` (
`id_reservasi` int(11)
,`id_customer` int(11)
,`id_pekerja` int(11)
,`id_kamar` int(11)
,`id_addon` int(11)
,`check_in` date
,`check_out` date
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `reservasi_berjalan`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `reservasi_berjalan` (
`id_reservasi` int(11)
,`id_customer` int(11)
,`id_pekerja` int(11)
,`id_kamar` int(11)
,`id_addon` int(11)
,`check_in` date
,`check_out` date
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `reservasi_usang`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `reservasi_usang` (
`id_reservasi` int(11)
,`id_customer` int(11)
,`id_pekerja` int(11)
,`id_kamar` int(11)
,`id_addon` int(11)
,`check_in` date
,`check_out` date
);

-- --------------------------------------------------------

--
-- Struktur untuk view `reservasi_belum_berjalan`
--
DROP TABLE IF EXISTS `reservasi_belum_berjalan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `reservasi_belum_berjalan`  AS SELECT `reservasi`.`id_reservasi` AS `id_reservasi`, `reservasi`.`id_customer` AS `id_customer`, `reservasi`.`id_pekerja` AS `id_pekerja`, `reservasi`.`id_kamar` AS `id_kamar`, `reservasi`.`id_addon` AS `id_addon`, `reservasi`.`check_in` AS `check_in`, `reservasi`.`check_out` AS `check_out` FROM `reservasi` WHERE curdate() < `reservasi`.`check_in` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `reservasi_berjalan`
--
DROP TABLE IF EXISTS `reservasi_berjalan`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `reservasi_berjalan`  AS SELECT `reservasi`.`id_reservasi` AS `id_reservasi`, `reservasi`.`id_customer` AS `id_customer`, `reservasi`.`id_pekerja` AS `id_pekerja`, `reservasi`.`id_kamar` AS `id_kamar`, `reservasi`.`id_addon` AS `id_addon`, `reservasi`.`check_in` AS `check_in`, `reservasi`.`check_out` AS `check_out` FROM `reservasi` WHERE curdate() between `reservasi`.`check_in` and `reservasi`.`check_out` ;

-- --------------------------------------------------------

--
-- Struktur untuk view `reservasi_usang`
--
DROP TABLE IF EXISTS `reservasi_usang`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `reservasi_usang`  AS SELECT `reservasi`.`id_reservasi` AS `id_reservasi`, `reservasi`.`id_customer` AS `id_customer`, `reservasi`.`id_pekerja` AS `id_pekerja`, `reservasi`.`id_kamar` AS `id_kamar`, `reservasi`.`id_addon` AS `id_addon`, `reservasi`.`check_in` AS `check_in`, `reservasi`.`check_out` AS `check_out` FROM `reservasi` WHERE curdate() > `reservasi`.`check_out` ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `add_on`
--
ALTER TABLE `add_on`
  ADD PRIMARY KEY (`id_add_on`),
  ADD KEY `id_pekerja` (`id_pekerja`);

--
-- Indeks untuk tabel `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`id_customer`);

--
-- Indeks untuk tabel `kamar`
--
ALTER TABLE `kamar`
  ADD PRIMARY KEY (`id_kamar`);

--
-- Indeks untuk tabel `pegawai`
--
ALTER TABLE `pegawai`
  ADD PRIMARY KEY (`id_pekerja`);

--
-- Indeks untuk tabel `reservasi`
--
ALTER TABLE `reservasi`
  ADD PRIMARY KEY (`id_reservasi`),
  ADD KEY `id_customer` (`id_customer`),
  ADD KEY `id_pekerja` (`id_pekerja`),
  ADD KEY `id_kamar` (`id_kamar`),
  ADD KEY `id_addon` (`id_addon`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `add_on`
--
ALTER TABLE `add_on`
  MODIFY `id_add_on` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT untuk tabel `customer`
--
ALTER TABLE `customer`
  MODIFY `id_customer` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT untuk tabel `kamar`
--
ALTER TABLE `kamar`
  MODIFY `id_kamar` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT untuk tabel `pegawai`
--
ALTER TABLE `pegawai`
  MODIFY `id_pekerja` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT untuk tabel `reservasi`
--
ALTER TABLE `reservasi`
  MODIFY `id_reservasi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `add_on`
--
ALTER TABLE `add_on`
  ADD CONSTRAINT `add_on_ibfk_1` FOREIGN KEY (`id_pekerja`) REFERENCES `pegawai` (`id_pekerja`);

--
-- Ketidakleluasaan untuk tabel `reservasi`
--
ALTER TABLE `reservasi`
  ADD CONSTRAINT `reservasi_ibfk_1` FOREIGN KEY (`id_customer`) REFERENCES `customer` (`id_customer`),
  ADD CONSTRAINT `reservasi_ibfk_2` FOREIGN KEY (`id_pekerja`) REFERENCES `pegawai` (`id_pekerja`),
  ADD CONSTRAINT `reservasi_ibfk_3` FOREIGN KEY (`id_kamar`) REFERENCES `kamar` (`id_kamar`),
  ADD CONSTRAINT `reservasi_ibfk_4` FOREIGN KEY (`id_addon`) REFERENCES `add_on` (`id_add_on`);

DELIMITER $$
--
-- Event
--
CREATE DEFINER=`root`@`localhost` EVENT `set_kamar_kosong` ON SCHEDULE EVERY 1 DAY STARTS '2023-12-27 01:18:59' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    UPDATE kamar
    SET status_kamar = 'Kosong'
    WHERE id_kamar IN (
        SELECT r.id_kamar
        FROM reservasi r
        WHERE CURRENT_DATE > r.check_out
    );
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
