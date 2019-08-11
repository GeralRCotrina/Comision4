-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 07-08-2019 a las 04:17:29
-- Versión del servidor: 10.1.35-MariaDB
-- Versión de PHP: 7.2.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `comision05`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `InsertarPar` (IN `vnombre` VARCHAR(45), `vhas_sembradas` VARCHAR(12), `vtotal_has` VARCHAR(50), `vdescripcion` VARCHAR(45), `vtipo` VARCHAR(15))  BEGIN
/*DECLARE nombre varchar(45)*/
INSERT INTO parcela (nombre,has_sembradas,total_has) VALUES (vnombre,vhas_sembradas,vtotal_has);
INSERT INTO reparto (descripcion,tipo) VALUES (vdescripcion,vtipo);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cant_por_reparto` ()  NO SQL
SELECT  DISTINCT
	re.id_reparto as id,
	re.fecha_reparto as fecha,
    (SELECT COUNT(*) FROM orden_riego WHERE id_reparto = re.id_reparto) as cantidad
FROM reparto re
inner join orden_riego orr
	on orr.id_reparto=re.id_reparto$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_hoja_asistencia` (IN `id_asmb` INT)  BEGIN
SET lc_time_names = 'es_ES';
SELECT  
        ha.id_hoja_asistencia as Item,
        CONCAT( a.first_name,' ',a.last_name) as usuario,
        ha.estado as estado,
        Date_format(ha.hora,'%h:%i %p')as hora
     
FROM hoja_asistencia ha
INNER JOIN auth_user a
	ON a.id=ha.id_auth_user
WHERE ha.id_asamblea = id_asmb
ORDER BY ha.estado, ha.hora;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_imprimir_ordenes` (IN `id_repar` INT)  BEGIN
SET lc_time_names = 'es_ES';
SELECT 	
		r.tipo as tipo,
        ord.id_orden_riego as recibo,
        r.fecha_reparto as fecha_reparto,
        c.nombre as canal,
        CONCAT(UPPER(u.last_name),', ',SUBSTRING_INDEX(u.first_name, ' ',1))  as usuario,
        p.nombre as parcela,
        p.num_toma as toma,
        Date_format(ord.fecha_inicio,'%Y/%M/%d') as fecha,
        Date_format(ord.fecha_inicio,'%h:%i %p')as inicio,
        ord.duracion as horas,
        CONCAT('S/. ',ord.importe) as importe
FROM orden_riego ord
INNER JOIN  reparto r
	on r.id_reparto=ord.id_reparto
INNER JOIN parcela p
	ON ord.id_parcela=p.id_parcela
INNER JOIN auth_user u
	ON p.id_auth_user=u.id
INNER JOIN canal c
	ON p.id_canal=c.id_canal
WHERE r.id_reparto = id_repar and ord.estado='Aprobada'
ORDER BY c.id_canal,p.num_toma,u.id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_imp_orden` (IN `id_ord` INT)  BEGIN
SET lc_time_names = 'es_ES';
SELECT  
        r.tipo as tipo,
        ord.id_orden_riego as recibo,
        r.fecha_reparto as fecha_reparto,
        c.nombre as canal,
        CONCAT(UPPER(u.last_name),', ',SUBSTRING_INDEX(u.first_name, ' ',1))  as usuario,
        p.nombre as parcela,
        p.num_toma as toma,
        Date_format(ord.fecha_inicio,'%Y/%M/%d') as fecha,
        Date_format(ord.fecha_inicio,'%h:%i %p')as inicio,
        ord.duracion as horas,
        CONCAT('S/. ',ord.importe) as importe
FROM orden_riego ord
INNER JOIN  reparto r
    on r.id_reparto=ord.id_reparto
INNER JOIN parcela p
    ON ord.id_parcela=p.id_parcela
INNER JOIN auth_user u
    ON p.id_auth_user=u.id
INNER JOIN canal c
    ON p.id_canal=c.id_canal
WHERE ord.id_orden_riego = id_ord;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_jugando1` (IN `id_repar` INT)  BEGIN
	DECLARE fecha date ;
	DECLARE cont int;
    DECLARE ids int;
    SET ids = (SELECT id_orden_riego from orden_riego WHERE id_orden_riego = (SELECT min(id_orden_riego) from orden_riego));
    SET cont = (SELECT COUNT(*) from orden_riego WHERE id_reparto = id_repar);
    set fecha = (SELECT fecha_inicio 
                 from orden_riego 
                 WHERE id_orden_riego=(select min(id_orden_riego) from orden_riego) and id_reparto = id_repar);
                    
    WHILE cont> 0 DO    	
      SELECT * FROM orden_riego WHERE id_orden_riego = ids;
      SET ids = ids +1;
      SET cont = cont - 1 ;
    END WHILE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ordenes_por_reparto_por_canal` ()  NO SQL
SELECT  DISTINCT
	re.id_reparto as id_reparto,
	re.fecha_reparto as fecha,
    ca.nombre as canal,
    ca.id_canal as id_canal,
    (SELECT COUNT(*) FROM orden_riego WHERE id_reparto = re.id_reparto and pa.id_canal= ca.id_canal) as cantidad
FROM reparto re
inner join orden_riego orr
	on orr.id_reparto=re.id_reparto
inner join parcela pa
	on pa.id_parcela = orr.id_parcela
inner join canal ca 
	on ca.id_canal = pa.id_canal
order by re.id_reparto,ca.id_canal$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_prueba` ()  BEGIN
 DECLARE v1 INT DEFAULT 5;
 DECLARE tam int;
 SET @tam = (SELECT COUNT(*) FROM datos_personales);

  WHILE v1 > 0 DO
    SELECT v1 as V11;
    set v1 = v1 -1;
  END WHILE;
  
  SELECT @tam as TAMM;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registro_rapido` (IN `vnombres` VARCHAR(30), `vapellidos` VARCHAR(150), `valias` VARCHAR(20), `vcelular` CHAR(13), `vdni` CHAR(8), `vfecha_nacimiento` DATE, `vfoto` VARCHAR(150), `vsexo` CHAR(1), `vtelefono` VARCHAR(20))  BEGIN
	DECLARE Id int;
    DECLARE vusername varchar(150);
    DECLARE vcontrasena varchar(128);
    
    set vusername = vdni;
    set vcontrasena = vdni;
    
    INSERT INTO auth_user(first_name,last_name,username,password) 
    	VALUES (vnombres,vapellidos,vusername,vcontrasena);
    
    set Id = (SELECT id FROM auth_user ORDER BY id DESC LIMIT 1);
    set vusername = vdni;

    INSERT INTO datos_personales(alias,celular,dni,fecha_nacimiento,foto,id_auth_user,sexo,telefono) 
        VALUES(valias,vcelular,vdni,vfecha_nacimiento,vfoto,Id,vsexo,vtelefono);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_rep_reparto` ()  NO SQL
SELECT 
	re.tipo as reparto,
	ord.id_orden_riego as id_orden,
    pa.num_toma as toma,
    ord.fecha_establecida as fecha,
    ord.duracion as hectareas,
    ca.nombre as canal,
    au.first_name as usuario   
FROM orden_riego ord

INNER JOIN parcela pa
 ON ord.id_parcela = pa.id_parcela
 
INNER JOIN canal ca
	ON ca.id_canal = pa.id_canal
    
INNER JOIN auth_user au 
	ON pa.id_auth_user=au.id
    
INNER JOIN reparto re
	ON ord.id_reparto=re.id_reparto
    
ORDER BY re.tipo ,ca.id_canal,pa.num_toma$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `agenda_asamblea`
--

CREATE TABLE `agenda_asamblea` (
  `id_agenda` int(11) NOT NULL,
  `id_asamblea` int(11) DEFAULT NULL,
  `punto_numero` int(11) DEFAULT NULL,
  `descripcion` varchar(400) COLLATE hp8_bin DEFAULT NULL,
  `foto` varchar(150) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `agenda_asamblea`
--

INSERT INTO `agenda_asamblea` (`id_agenda`, `id_asamblea`, `punto_numero`, `descripcion`, `foto`) VALUES
(37, 62, 2, '1.- xsaDSAdsa', NULL),
(38, 62, 2, '2.- DSADSA', NULL),
(40, 65, 1, '1.- fdwfrew', NULL),
(42, 68, 1, '1.- 555', NULL),
(43, 69, 1, '1.- De todo un poco.', NULL),
(44, 71, 1, '1.- aadssd', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `archivos_parcela`
--

CREATE TABLE `archivos_parcela` (
  `id_archivos_parcela` int(11) NOT NULL,
  `id_parcela` int(11) DEFAULT NULL,
  `descripcion` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `archivo` varchar(150) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asamblea`
--

CREATE TABLE `asamblea` (
  `id_asamblea` int(11) NOT NULL,
  `tipo` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `descripcion` varchar(300) COLLATE hp8_bin DEFAULT NULL,
  `fecha_registro` datetime DEFAULT NULL,
  `fecha_asamblea` datetime DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `asamblea`
--

INSERT INTO `asamblea` (`id_asamblea`, `tipo`, `descripcion`, `fecha_registro`, `fecha_asamblea`, `estado`) VALUES
(62, 'General', 'Una buena descripción.', '2019-07-29 02:41:21', '2019-07-08 12:12:00', '2'),
(65, 'General', 'fefreqwfer', '2019-07-29 03:09:15', '2019-07-30 12:12:00', '1'),
(68, 'General', 'Acá ponemos una bonita descripción pues.', '2019-07-29 04:21:36', '2019-07-08 05:05:00', '2'),
(69, 'General', 'Asamblea general.', '2019-07-30 00:12:22', '2019-07-31 12:12:00', '3'),
(71, 'General', 'ddd', '2019-08-01 01:32:57', '2019-08-09 12:12:00', '2');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_group`
--

CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL,
  `name` varchar(150) COLLATE hp8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_group_permissions`
--

CREATE TABLE `auth_group_permissions` (
  `id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_permission`
--

CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL,
  `name` varchar(255) COLLATE hp8_bin NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) COLLATE hp8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `auth_permission`
--

INSERT INTO `auth_permission` (`id`, `name`, `content_type_id`, `codename`) VALUES
(1, 'Can add log entry', 1, 'add_logentry'),
(2, 'Can change log entry', 1, 'change_logentry'),
(3, 'Can delete log entry', 1, 'delete_logentry'),
(4, 'Can view log entry', 1, 'view_logentry'),
(5, 'Can add permission', 2, 'add_permission'),
(6, 'Can change permission', 2, 'change_permission'),
(7, 'Can delete permission', 2, 'delete_permission'),
(8, 'Can view permission', 2, 'view_permission'),
(9, 'Can add group', 3, 'add_group'),
(10, 'Can change group', 3, 'change_group'),
(11, 'Can delete group', 3, 'delete_group'),
(12, 'Can view group', 3, 'view_group'),
(13, 'Can add user', 4, 'add_user'),
(14, 'Can change user', 4, 'change_user'),
(15, 'Can delete user', 4, 'delete_user'),
(16, 'Can view user', 4, 'view_user'),
(17, 'Can add content type', 5, 'add_contenttype'),
(18, 'Can change content type', 5, 'change_contenttype'),
(19, 'Can delete content type', 5, 'delete_contenttype'),
(20, 'Can view content type', 5, 'view_contenttype'),
(21, 'Can add session', 6, 'add_session'),
(22, 'Can change session', 6, 'change_session'),
(23, 'Can delete session', 6, 'delete_session'),
(24, 'Can view session', 6, 'view_session'),
(25, 'Can add acceso', 7, 'add_acceso'),
(26, 'Can change acceso', 7, 'change_acceso'),
(27, 'Can delete acceso', 7, 'delete_acceso'),
(28, 'Can view acceso', 7, 'view_acceso'),
(29, 'Can add asamblea', 8, 'add_asamblea'),
(30, 'Can change asamblea', 8, 'change_asamblea'),
(31, 'Can delete asamblea', 8, 'delete_asamblea'),
(32, 'Can view asamblea', 8, 'view_asamblea'),
(33, 'Can add asistencia', 9, 'add_asistencia'),
(34, 'Can change asistencia', 9, 'change_asistencia'),
(35, 'Can delete asistencia', 9, 'delete_asistencia'),
(36, 'Can view asistencia', 9, 'view_asistencia'),
(37, 'Can add canal', 10, 'add_canal'),
(38, 'Can change canal', 10, 'change_canal'),
(39, 'Can delete canal', 10, 'delete_canal'),
(40, 'Can view canal', 10, 'view_canal'),
(41, 'Can add caudal', 11, 'add_caudal'),
(42, 'Can change caudal', 11, 'change_caudal'),
(43, 'Can delete caudal', 11, 'delete_caudal'),
(44, 'Can view caudal', 11, 'view_caudal'),
(45, 'Can add comite', 12, 'add_comite'),
(46, 'Can change comite', 12, 'change_comite'),
(47, 'Can delete comite', 12, 'delete_comite'),
(48, 'Can view comite', 12, 'view_comite'),
(49, 'Can add comprobante', 13, 'add_comprobante'),
(50, 'Can change comprobante', 13, 'change_comprobante'),
(51, 'Can delete comprobante', 13, 'delete_comprobante'),
(52, 'Can view comprobante', 13, 'view_comprobante'),
(53, 'Can add destajo', 14, 'add_destajo'),
(54, 'Can change destajo', 14, 'change_destajo'),
(55, 'Can delete destajo', 14, 'delete_destajo'),
(56, 'Can view destajo', 14, 'view_destajo'),
(57, 'Can add det limpieza', 15, 'add_detlimpieza'),
(58, 'Can change det limpieza', 15, 'change_detlimpieza'),
(59, 'Can delete det limpieza', 15, 'delete_detlimpieza'),
(60, 'Can view det limpieza', 15, 'view_detlimpieza'),
(61, 'Can add det lista', 16, 'add_detlista'),
(62, 'Can change det lista', 16, 'change_detlista'),
(63, 'Can delete det lista', 16, 'delete_detlista'),
(64, 'Can view det lista', 16, 'view_detlista'),
(65, 'Can add direccion', 17, 'add_direccion'),
(66, 'Can change direccion', 17, 'change_direccion'),
(67, 'Can delete direccion', 17, 'delete_direccion'),
(68, 'Can view direccion', 17, 'view_direccion'),
(69, 'Can add limpieza', 18, 'add_limpieza'),
(70, 'Can change limpieza', 18, 'change_limpieza'),
(71, 'Can delete limpieza', 18, 'delete_limpieza'),
(72, 'Can view limpieza', 18, 'view_limpieza'),
(73, 'Can add lista', 19, 'add_lista'),
(74, 'Can change lista', 19, 'change_lista'),
(75, 'Can delete lista', 19, 'delete_lista'),
(76, 'Can view lista', 19, 'view_lista'),
(77, 'Can add multa', 20, 'add_multa'),
(78, 'Can change multa', 20, 'change_multa'),
(79, 'Can delete multa', 20, 'delete_multa'),
(80, 'Can view multa', 20, 'view_multa'),
(81, 'Can add noticia', 21, 'add_noticia'),
(82, 'Can change noticia', 21, 'change_noticia'),
(83, 'Can delete noticia', 21, 'delete_noticia'),
(84, 'Can view noticia', 21, 'view_noticia'),
(85, 'Can add obra', 22, 'add_obra'),
(86, 'Can change obra', 22, 'change_obra'),
(87, 'Can delete obra', 22, 'delete_obra'),
(88, 'Can view obra', 22, 'view_obra'),
(89, 'Can add orden riego', 23, 'add_ordenriego'),
(90, 'Can change orden riego', 23, 'change_ordenriego'),
(91, 'Can delete orden riego', 23, 'delete_ordenriego'),
(92, 'Can view orden riego', 23, 'view_ordenriego'),
(93, 'Can add parcela', 24, 'add_parcela'),
(94, 'Can change parcela', 24, 'change_parcela'),
(95, 'Can delete parcela', 24, 'delete_parcela'),
(96, 'Can view parcela', 24, 'view_parcela'),
(97, 'Can add persona', 25, 'add_persona'),
(98, 'Can change persona', 25, 'change_persona'),
(99, 'Can delete persona', 25, 'delete_persona'),
(100, 'Can view persona', 25, 'view_persona'),
(101, 'Can add reparto', 26, 'add_reparto'),
(102, 'Can change reparto', 26, 'change_reparto'),
(103, 'Can delete reparto', 26, 'delete_reparto'),
(104, 'Can view reparto', 26, 'view_reparto'),
(105, 'Can add talonario', 27, 'add_talonario'),
(106, 'Can change talonario', 27, 'change_talonario'),
(107, 'Can delete talonario', 27, 'delete_talonario'),
(108, 'Can view talonario', 27, 'view_talonario'),
(109, 'Can add usuario', 28, 'add_usuario'),
(110, 'Can change usuario', 28, 'change_usuario'),
(111, 'Can delete usuario', 28, 'delete_usuario'),
(112, 'Can view usuario', 28, 'view_usuario'),
(113, 'Can add agenda asamblea', 29, 'add_agendaasamblea'),
(114, 'Can change agenda asamblea', 29, 'change_agendaasamblea'),
(115, 'Can delete agenda asamblea', 29, 'delete_agendaasamblea'),
(116, 'Can view agenda asamblea', 29, 'view_agendaasamblea'),
(117, 'Can add archivos parcela', 30, 'add_archivosparcela'),
(118, 'Can change archivos parcela', 30, 'change_archivosparcela'),
(119, 'Can delete archivos parcela', 30, 'delete_archivosparcela'),
(120, 'Can view archivos parcela', 30, 'view_archivosparcela'),
(121, 'Can add auth group', 31, 'add_authgroup'),
(122, 'Can change auth group', 31, 'change_authgroup'),
(123, 'Can delete auth group', 31, 'delete_authgroup'),
(124, 'Can view auth group', 31, 'view_authgroup'),
(125, 'Can add auth group permissions', 32, 'add_authgrouppermissions'),
(126, 'Can change auth group permissions', 32, 'change_authgrouppermissions'),
(127, 'Can delete auth group permissions', 32, 'delete_authgrouppermissions'),
(128, 'Can view auth group permissions', 32, 'view_authgrouppermissions'),
(129, 'Can add auth permission', 33, 'add_authpermission'),
(130, 'Can change auth permission', 33, 'change_authpermission'),
(131, 'Can delete auth permission', 33, 'delete_authpermission'),
(132, 'Can view auth permission', 33, 'view_authpermission'),
(133, 'Can add auth user', 34, 'add_authuser'),
(134, 'Can change auth user', 34, 'change_authuser'),
(135, 'Can delete auth user', 34, 'delete_authuser'),
(136, 'Can view auth user', 34, 'view_authuser'),
(137, 'Presidente', 34, 'es_presidente'),
(138, 'Canalero', 34, 'es_canalero'),
(139, 'Tesorero', 34, 'es_tesorero'),
(140, 'Vocal', 34, 'es_vocal'),
(141, 'Usuario', 34, 'es_usuario'),
(142, 'Can add auth user groups', 35, 'add_authusergroups'),
(143, 'Can change auth user groups', 35, 'change_authusergroups'),
(144, 'Can delete auth user groups', 35, 'delete_authusergroups'),
(145, 'Can view auth user groups', 35, 'view_authusergroups'),
(146, 'Can add auth user user permissions', 36, 'add_authuseruserpermissions'),
(147, 'Can change auth user user permissions', 36, 'change_authuseruserpermissions'),
(148, 'Can delete auth user user permissions', 36, 'delete_authuseruserpermissions'),
(149, 'Can view auth user user permissions', 36, 'view_authuseruserpermissions'),
(150, 'Can add datos personales', 37, 'add_datospersonales'),
(151, 'Can change datos personales', 37, 'change_datospersonales'),
(152, 'Can delete datos personales', 37, 'delete_datospersonales'),
(153, 'Can view datos personales', 37, 'view_datospersonales'),
(154, 'Can add django admin log', 38, 'add_djangoadminlog'),
(155, 'Can change django admin log', 38, 'change_djangoadminlog'),
(156, 'Can delete django admin log', 38, 'delete_djangoadminlog'),
(157, 'Can view django admin log', 38, 'view_djangoadminlog'),
(158, 'Can add django content type', 39, 'add_djangocontenttype'),
(159, 'Can change django content type', 39, 'change_djangocontenttype'),
(160, 'Can delete django content type', 39, 'delete_djangocontenttype'),
(161, 'Can view django content type', 39, 'view_djangocontenttype'),
(162, 'Can add django migrations', 40, 'add_djangomigrations'),
(163, 'Can change django migrations', 40, 'change_djangomigrations'),
(164, 'Can delete django migrations', 40, 'delete_djangomigrations'),
(165, 'Can view django migrations', 40, 'view_djangomigrations'),
(166, 'Can add django session', 41, 'add_djangosession'),
(167, 'Can change django session', 41, 'change_djangosession'),
(168, 'Can delete django session', 41, 'delete_djangosession'),
(169, 'Can view django session', 41, 'view_djangosession'),
(170, 'Can add hoja asistencia', 42, 'add_hojaasistencia'),
(171, 'Can change hoja asistencia', 42, 'change_hojaasistencia'),
(172, 'Can delete hoja asistencia', 42, 'delete_hojaasistencia'),
(173, 'Can view hoja asistencia', 42, 'view_hojaasistencia'),
(174, 'Can add comp multa', 43, 'add_compmulta'),
(175, 'Can change comp multa', 43, 'change_compmulta'),
(176, 'Can delete comp multa', 43, 'delete_compmulta'),
(177, 'Can view comp multa', 43, 'view_compmulta'),
(178, 'Can add comp orden', 44, 'add_comporden'),
(179, 'Can change comp orden', 44, 'change_comporden'),
(180, 'Can delete comp orden', 44, 'delete_comporden'),
(181, 'Can view comp orden', 44, 'view_comporden'),
(182, 'Can add multa asistencia', 45, 'add_multaasistencia'),
(183, 'Can change multa asistencia', 45, 'change_multaasistencia'),
(184, 'Can delete multa asistencia', 45, 'delete_multaasistencia'),
(185, 'Can view multa asistencia', 45, 'view_multaasistencia'),
(186, 'Can add multa limpia', 46, 'add_multalimpia'),
(187, 'Can change multa limpia', 46, 'change_multalimpia'),
(188, 'Can delete multa limpia', 46, 'delete_multalimpia'),
(189, 'Can view multa limpia', 46, 'view_multalimpia'),
(190, 'Can add multa orden', 47, 'add_multaorden'),
(191, 'Can change multa orden', 47, 'change_multaorden'),
(192, 'Can delete multa orden', 47, 'delete_multaorden'),
(193, 'Can view multa orden', 47, 'view_multaorden'),
(194, 'Can add det asamb canal', 48, 'add_detasambcanal'),
(195, 'Can change det asamb canal', 48, 'change_detasambcanal'),
(196, 'Can delete det asamb canal', 48, 'delete_detasambcanal'),
(197, 'Can view det asamb canal', 48, 'view_detasambcanal');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_user`
--

CREATE TABLE `auth_user` (
  `id` int(11) NOT NULL,
  `password` varchar(128) COLLATE hp8_bin NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) COLLATE hp8_bin NOT NULL,
  `first_name` varchar(30) COLLATE hp8_bin NOT NULL,
  `last_name` varchar(150) COLLATE hp8_bin NOT NULL,
  `email` varchar(254) COLLATE hp8_bin NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  `dni` varchar(8) COLLATE hp8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `auth_user`
--

INSERT INTO `auth_user` (`id`, `password`, `last_login`, `is_superuser`, `username`, `first_name`, `last_name`, `email`, `is_staff`, `is_active`, `date_joined`, `dni`) VALUES
(1, 'pbkdf2_sha256$150000$9PjEvjWaocDj$YeVw0RMguNFrLWwIzPnF5P2RzZD3rBvg7pFNaApaUh8=', '2019-08-06 04:39:46.689229', 1, 'grcl', 'Geral R', '[Desarrollador]', 'lareg.yors@gmail.com', 1, 1, '2018-10-24 13:32:59.769234', '76583884'),
(2, 'pbkdf2_sha256$150000$3125dCTPvjNy$x6ITkc93/Z3ZOHrg0aIleKhGif4j0GJkeGCtBkOmru4=', '2019-08-06 00:20:26.073593', 0, 'Presidente', 'Domingo Pelayo', 'Sanchez Vilchez', 'dpelayo@gmail.com', 0, 1, '2018-10-24 13:55:47.000000', '27911359'),
(3, 'pbkdf2_sha256$150000$Lq2U2CmDOGIJ$/PxKCL2Wcwp+Laxeci08WqiU5Q6Ox/r1De6BU3uyLcs=', '2019-08-06 00:22:39.719096', 0, 'Canalero', 'Saul', 'Cieza', 'scieza@hotmail.com', 0, 1, '2018-10-24 13:57:47.000000', '10000007'),
(5, 'pbkdf2_sha256$120000$iq4pABZBLoQ1$z4W+Bhp0w90w9KUyqgHr3Ox/0xtRDp2GP3iMg7bekc8=', '2019-02-13 21:29:24.969332', 0, 'Vocal', 'Roger', 'Gonzales Chuan', 'rgonzales@gmail.com', 0, 1, '2018-10-24 21:54:31.409353', '45939181'),
(6, 'pbkdf2_sha256$150000$UIdPZp7x0P02$SsmjUd49Ttb/9s83Bd9Sv3eyL84hA1iwsk+Q2nmCUxQ=', '2019-07-29 07:14:03.834397', 0, 'paredes@27916871', 'María Consuelo ', 'Paredes DÍaz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27916871'),
(7, 'pbkdf2_sha256$150000$MbAI3REFoOHH$qntSPmSRp9I/ZsEAi5/tiBXZHrKwQA78IVmNYqXgOwY=', '2019-07-29 07:17:50.434758', 0, 'pereda@27920554', 'Josué Ramón ', 'Pereda Rojas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27920554'),
(8, 'pbkdf2_sha256$150000$AbmIUGZqhQT0$San6wMsFB5qS98DbVwNmoQB3XloXXUqlZUcY/u7hvrQ=', '2019-08-06 04:38:05.110316', 0, 'arbildo@44500169', 'Julio Henry ', 'Arbildo Chavarry', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44500169'),
(9, 'pbkdf2_sha256$150000$NUNkv76tuKKB$PJ59czyKHB5QR59jleWrYZgH7OAcxI16zDbARuK2Xm0=', '2019-08-06 04:37:11.553652', 0, 'tirado@27925153', 'Samuel Porfirio ', 'Tirado Sánchez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27925153'),
(10, 'pbkdf2_sha256$150000$6vIuAEfZ2tjV$DGZrztoK8ARaejk5pfW6jqwImmhdBTsUuLuYEJsizzQ=', '2019-08-06 04:35:44.212174', 0, 'santos@10567740', 'Nicolás Edwin ', 'Santos Arce', 'null', 0, 1, '0000-00-00 00:00:00.000000', '10567740'),
(11, 'pbkdf2_sha256$150000$5aUBadP0l4uK$IOCZmhp8VduVLo+ZSap0dRKziY1ROqJh07B3e3tCz34=', '2019-08-06 04:32:55.928944', 0, 'ortiz@27041401', 'Hilda Rosa ', 'Ortiz Cotrina', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27041401'),
(12, 'lc@17837106', '0000-00-00 00:00:00.000000', 0, 'arce@17837106', 'Lina Beatriz ', 'Arce Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '17837106'),
(13, 'pbkdf2_sha256$150000$jNxrJSshp9d2$oJNQaod9E99IaO/xei5ssSs+MEM8QsMZUodw/XCF36Q=', '2019-08-06 04:39:08.566734', 0, 'rojas@08938592', 'José Pablo ', 'Rojas Carrera', 'null', 0, 1, '0000-00-00 00:00:00.000000', '08938592'),
(14, 'ac@47701484', '0000-00-00 00:00:00.000000', 0, 'mendoza@47701484', 'Augusto Segundo ', 'Mendoza Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '47701484'),
(15, 'jm@17975860', '0000-00-00 00:00:00.000000', 0, 'carrera@17975860', 'José Amado ', 'Carrera Marín', 'null', 0, 1, '0000-00-00 00:00:00.000000', '17975860'),
(16, 'mm@27901508', '0000-00-00 00:00:00.000000', 0, 'carrera@27901508', 'Mario Herminio ', 'Carrera Marín', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27901508'),
(17, 'lp@27904969', '0000-00-00 00:00:00.000000', 0, 'abanto@27904969', 'Luis', 'Abanto Paredes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27904969'),
(18, 'jm@27900194', '0000-00-00 00:00:00.000000', 0, 'carrera@27900194', 'Juan de la Cruz', 'Carrera Marín', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27900194'),
(19, 'eq@26616098', '0000-00-00 00:00:00.000000', 0, 'cotrina@26616098', 'Eladio', 'Cotrina Quispe', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26616098'),
(20, 'jp@19328772', '0000-00-00 00:00:00.000000', 0, 'sanchez@19328772', 'Jesús Bernardo ', 'Sánchez Paz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19328772'),
(21, 'jd@48419583', '0000-00-00 00:00:00.000000', 0, 'cordero@48419583', 'José Luis ', 'Cordero del Pino', 'null', 0, 1, '0000-00-00 00:00:00.000000', '48419583'),
(22, 'jp@19260042', '0000-00-00 00:00:00.000000', 0, 'castañeda@19260042', 'Juana Doraliza ', 'Castañeda Paredes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19260042'),
(23, 'cc@42811950', '0000-00-00 00:00:00.000000', 0, 'gonzales@42811950', 'Ceyner', 'Gonzáles Chuan', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42811950'),
(24, 'pa@27916060', '0000-00-00 00:00:00.000000', 0, 'briones@27916060', 'Pedro', 'Briones Acosta', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27916060'),
(25, 'cm@00000000', '0000-00-00 00:00:00.000000', 0, 'vasquez@07538471', 'Clemente ', 'Vásquez Medina', 'null', 0, 1, '0000-00-00 00:00:00.000000', '07538471'),
(26, 'sb@26729717', '0000-00-00 00:00:00.000000', 0, 'narva@26729717', 'Sonia Ronnaly ', 'Narva Barrantes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26729717'),
(27, 'sa@07579160', '0000-00-00 00:00:00.000000', 0, 'briones@07579160', 'Segundo Félix ', 'Briones Acosta', 'null', 0, 1, '0000-00-00 00:00:00.000000', '07579160'),
(28, 'jo@25842560', '0000-00-00 00:00:00.000000', 0, 'cotrina@25842560', 'José Wilmer ', 'Cotrina Olortegui', 'null', 0, 1, '0000-00-00 00:00:00.000000', '25842560'),
(29, 'bm@03382668', '0000-00-00 00:00:00.000000', 0, 'cordova@03382668', 'Balvina ', 'Córdova Mondragón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '03382668'),
(30, 'nm@07538471', '0000-00-00 00:00:00.000000', 0, 'castañeda@07538471', 'Nelson Rafael ', 'Castañeda Muñoz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '07538471'),
(31, 'dm@27913786', '0000-00-00 00:00:00.000000', 0, 'lezama@27913786', 'Dominga Elizabet ', 'Lezama Mendoza ', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27913786'),
(32, 'sa@19260049', '0000-00-00 00:00:00.000000', 0, 'olortegui@19260049', 'Segundo Claudio ', 'Olortegui Acosta', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19260049'),
(33, 'rm@27911098', '0000-00-00 00:00:00.000000', 0, 'castañeda@27911098', 'Regina Tomasa ', 'Castañeda Muñoz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27911098'),
(34, 'jv@19258711', '0000-00-00 00:00:00.000000', 0, 'sanchez@19258711', 'José Celestino ', 'Sánchez Vargas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19258711'),
(35, 'mc@26694937', '0000-00-00 00:00:00.000000', 0, 'correa@26694937', 'Martha Rossana ', 'Correa Cabanillas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26694937'),
(36, 'fb@27926644', '0000-00-00 00:00:00.000000', 0, 'ramirez@27926644', 'Felécitas ', 'Ramírez Bueno', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27926644'),
(37, 'c @19242421', '0000-00-00 00:00:00.000000', 0, 'vasquez@19242421', 'Carmen Rosa ', 'Vásquez  Fernández ', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19242421'),
(38, 'ec@27923319', '0000-00-00 00:00:00.000000', 0, 'abanto@27923319', 'Eligio ', 'Abanto Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27923319'),
(39, 'ac@42186329', '0000-00-00 00:00:00.000000', 0, 'mendoza@42186329', 'Any Yaneth ', 'Mendoza Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42186329'),
(40, 'ja@27904660', '0000-00-00 00:00:00.000000', 0, 'briones@27904660', 'Jesús ', 'Briones Acosta', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27904660'),
(41, 'fs@09091088', '0000-00-00 00:00:00.000000', 0, 'perez@09091088', 'Felicitas ', 'Perez Sánchez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '09091088'),
(42, 'jr@19239343', '0000-00-00 00:00:00.000000', 0, 'balarezo@19239343', 'José Antonio ', 'Balarezo Rocha', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19239343'),
(43, 'mr@17813980', '0000-00-00 00:00:00.000000', 0, 'vega@17813980', 'María Enma ', 'Vega Rivera', 'null', 0, 1, '0000-00-00 00:00:00.000000', '17813980'),
(44, 'gr@26640965', '0000-00-00 00:00:00.000000', 0, 'mendoza@26640965', 'Graciano ', 'Mendoza Ruiz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26640965'),
(45, 'iq@19420925', '0000-00-00 00:00:00.000000', 0, 'sanchez@19420925', 'Inocente ', 'Sánchez Quiroz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19420925'),
(46, 'ac@27911107', '0000-00-00 00:00:00.000000', 0, 'cotrina@27911107', 'Aldemar Inocencio ', 'Cotrina Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27911107'),
(47, 'sm@19261326', '0000-00-00 00:00:00.000000', 0, 'romero@19261326', 'Segundo Wilmer ', 'Romero Mendoza', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19261326'),
(48, 'dp@26608460', '0000-00-00 00:00:00.000000', 0, 'cleza@26608460', 'Diego Gilberto ', 'Cleza Padilla', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26608460'),
(49, 'vp@19218235', '0000-00-00 00:00:00.000000', 0, 'abanto@19218235', 'Valentín Severino ', 'Abanto Paredes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19218235'),
(50, 'gs@27921569', '0000-00-00 00:00:00.000000', 0, 'tirado@27921569', 'Gosvinda ', 'Tirado Sánchez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27921569'),
(51, 'jr@80456957', '0000-00-00 00:00:00.000000', 0, 'muñoz@80456957', 'José Jesés ', 'Muñóz Ríos', 'null', 0, 1, '0000-00-00 00:00:00.000000', '80456957'),
(52, 'am@27928067', '0000-00-00 00:00:00.000000', 0, 'abanto@27928067', 'Ascensión Estanislao ', 'Abanto Moreno', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27928067'),
(53, 'gc@19212528', '0000-00-00 00:00:00.000000', 0, 'flores@19212528', 'Gerardo ', 'Flores Chuan', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19212528'),
(54, 'jc@28064764', '0000-00-00 00:00:00.000000', 0, 'burgos@28064764', 'Jacinto ', 'Burgos Cholán', 'null', 0, 1, '0000-00-00 00:00:00.000000', '28064764'),
(55, 'jm@27926916', '0000-00-00 00:00:00.000000', 0, 'alarcon@27926916', 'José Simón ', 'Alarcón Marín', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27926916'),
(56, 'mc@27916422', '0000-00-00 00:00:00.000000', 0, 'rios@27916422', 'Maria Megidia ', 'Ríos Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27916422'),
(57, 'ds@43314572', '0000-00-00 00:00:00.000000', 0, 'castañeda@43314572', 'Denis Berlyn ', 'Castañeda Sánchez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43314572'),
(58, 'mm@27902250', '0000-00-00 00:00:00.000000', 0, 'alarcon@27902250', 'Maximino ', 'Alarcón Marín', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27902250'),
(59, 'tp@06093479', '0000-00-00 00:00:00.000000', 0, 'jara@06093479', 'Teodosio ', 'Jara Perez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '06093479'),
(60, 'sc@42623449', '0000-00-00 00:00:00.000000', 0, 'abanto@42623449', 'Santos Fidel ', 'Abanto Carrera', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42623449'),
(61, 'ra@43546244', '0000-00-00 00:00:00.000000', 0, 'novoa@43546244', 'Renán ', 'Novoa Arlas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43546244'),
(62, 'aa@26626721', '0000-00-00 00:00:00.000000', 0, 'cerdan@26626721', 'Asunción ', 'Cerdan Abanto', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26626721'),
(63, 'jr@44666468', '0000-00-00 00:00:00.000000', 0, 'arias@44666468', 'José Wilmer ', 'Arias Rojas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44666468'),
(64, 'sr@45622883', '0000-00-00 00:00:00.000000', 0, 'fabian@45622883', 'Sirilo Concepción ', 'Fabian Rosas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '45622883'),
(65, 'aa@06637319', '0000-00-00 00:00:00.000000', 0, 'briones@06637319', 'Ambrosio Napoleon ', 'Briones Acosta', 'null', 0, 1, '0000-00-00 00:00:00.000000', '06637319'),
(66, 'mr@43509720', '0000-00-00 00:00:00.000000', 0, 'duran@43509720', 'María Dominica ', 'Duran Ruiz de Rojas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43509720'),
(67, 'ma@17975614', '0000-00-00 00:00:00.000000', 0, 'bejarano@17975614', 'Manuel Jesús ', 'Bejarano Alvarado', 'null', 0, 1, '0000-00-00 00:00:00.000000', '17975614'),
(68, 'ac@74600219', '0000-00-00 00:00:00.000000', 0, 'lelva@74600219', 'Angel Antonio ', 'lelva Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '74600219'),
(69, 'ac@45265774', '0000-00-00 00:00:00.000000', 0, 'leiva@45265774', 'Ana María ', 'leiva Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '45265774'),
(70, 'sc@43504257', '0000-00-00 00:00:00.000000', 0, 'lelva@43504257', 'Santa Adriana ', 'lelva Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43504257'),
(71, 'fc@42186924', '0000-00-00 00:00:00.000000', 0, 'leiva@42186924', 'Fabio Sebastian ', 'leiva Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42186924'),
(72, 'sc@40806777', '0000-00-00 00:00:00.000000', 0, 'leiva@40806777', 'Silverio Avelino ', 'leiva Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '40806777'),
(73, 'il@4668s803', '0000-00-00 00:00:00.000000', 0, 'pelon@4668s803', 'Isollna Concepción', 'Leiva Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '46685803'),
(74, 'jc@47906316', '0000-00-00 00:00:00.000000', 0, 'leiva@47906316', 'Juanita Bautista ', 'Leiva Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '47906316'),
(75, 'mc@26933968', '0000-00-00 00:00:00.000000', 0, 'rodriguez@26933968', 'Marciano ', 'Rodríguez Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26933968'),
(76, 'hm@10741510', '0000-00-00 00:00:00.000000', 0, 'vasquez@10741510', 'Humberto ', 'Vasquez Morales', 'null', 0, 1, '0000-00-00 00:00:00.000000', '10741510'),
(77, 'jj@18047708', '0000-00-00 00:00:00.000000', 0, 'muñoz@18047708', 'José Andrés ', 'Muñoz Jave', 'null', 0, 1, '0000-00-00 00:00:00.000000', '18047708'),
(78, 'mr@27929924', '0000-00-00 00:00:00.000000', 0, 'briones@27929924', 'Maritza Emperatriz ', 'Briones Rojas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27929924'),
(79, 'el@08334338', '0000-00-00 00:00:00.000000', 0, 'quispe@08334338', 'Epifanio Fredy ', 'Quispe López', 'null', 0, 1, '0000-00-00 00:00:00.000000', '08334338'),
(80, 'ec@27921605', '0000-00-00 00:00:00.000000', 0, 'agullar@27921605', 'Esteban Teofllo ', 'Agullar Chavez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27921605'),
(81, 'ma@07571604', '0000-00-00 00:00:00.000000', 0, 'chavez@07571604', 'Mario Lodorico ', 'Chavez Atildo', 'null', 0, 1, '0000-00-00 00:00:00.000000', '07571604'),
(82, 'pc@27906685', '0000-00-00 00:00:00.000000', 0, 'gonzales@27906685', 'Pedro ', 'Gonzales Carrera', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27906685'),
(83, 'hq@19328715', '0000-00-00 00:00:00.000000', 0, 'palomino@19328715', 'Hugo Percy ', 'Palomino Quiroz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19328715'),
(84, 'jb@33808544', '0000-00-00 00:00:00.000000', 0, 'llanos@33808544', 'Juan ', 'Llanos Barriente', 'null', 0, 1, '0000-00-00 00:00:00.000000', '33808544'),
(85, 'ja@26925262', '0000-00-00 00:00:00.000000', 0, 'abantos@26925262', 'Jaime ', 'Abantos Asaftero', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26925262'),
(86, 'li@44032706', '0000-00-00 00:00:00.000000', 0, 'carrera@44032706', 'Lelis Ivan ', 'Carrera Izquierdo', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44032706'),
(87, 'jc@25478809', '0000-00-00 00:00:00.000000', 0, 'honorio@25478809', 'José Benito ', 'Honorio Cruzado', 'null', 0, 1, '0000-00-00 00:00:00.000000', '25478809'),
(88, 'wc@19260043', '0000-00-00 00:00:00.000000', 0, 'olortegui@19260043', 'Wilder Roger ', 'Olortegui Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19260043'),
(89, 'fv@26722350', '0000-00-00 00:00:00.000000', 0, 'cabanillas@26722350', 'Felix ', 'Cabanillas Villanueva', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26722350'),
(90, 'lr@40666289', '0000-00-00 00:00:00.000000', 0, 'lezama@40666289', 'Ludgerio Benigno ', 'Lezama Rojas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '40666289'),
(91, 'sg@27745461', '0000-00-00 00:00:00.000000', 0, 'gregorio@27745461', 'Santos ', 'Gregorio Guerrero', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27745461'),
(92, 'mr@27902846', '0000-00-00 00:00:00.000000', 0, 'rojas@27902846', 'Modesto ', 'Rojas Ruiz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27902846'),
(93, 'vc@27910948', '0000-00-00 00:00:00.000000', 0, 'quiroz@27910948', 'Víctor Marciano ', 'Quiroz Cruzado', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27910948'),
(94, 'rl@41957768', '0000-00-00 00:00:00.000000', 0, 'cotrina@41957768', 'Robert Franklin ', 'Cotrina Lezama', 'null', 0, 1, '0000-00-00 00:00:00.000000', '41957768'),
(95, 'jm@46143897', '0000-00-00 00:00:00.000000', 0, 'sanchez@46143897', 'Jhonell Jesús ', 'Sánchez Muftoz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '46143897'),
(96, 'fp@27927921', '0000-00-00 00:00:00.000000', 0, 'muiloz@27927921', 'Felix Octavio ', 'Muñoz Pinedo', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27927921'),
(97, 'wp@44034409', '0000-00-00 00:00:00.000000', 0, 'sanchez@44034409', 'Wilder David ', 'Sánchez Paz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44034409'),
(98, 'kb@47s06740', '0000-00-00 00:00:00.000000', 0, 'suclupe@47s06740', 'Kevin Raúl ', 'Suclupe Bazan', 'null', 0, 1, '0000-00-00 00:00:00.000000', '47506740'),
(99, 'jm@47519976', '0000-00-00 00:00:00.000000', 0, 'sanchez@47519976', 'Jean Carlos ', 'Sánchez Muñoz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '47519976'),
(100, 'gv@71009442', '0000-00-00 00:00:00.000000', 0, 'vasquez@71009442', 'Gabriela Isabel ', 'Vásquez Vásquez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '71009442'),
(101, 'aa@26958782', '0000-00-00 00:00:00.000000', 0, 'calderon@26958782', 'Amella ', 'Calderón Acevedo', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26958782'),
(102, 'jh@27916429', '0000-00-00 00:00:00.000000', 0, 'urbina@27916429', 'José Ignacio ', 'Urbina Huaccha', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27916429'),
(103, 'aj@44182728', '0000-00-00 00:00:00.000000', 0, 'torres@44182728', 'Alexander ', 'Torres Jimenez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44182728'),
(104, 'mh@00000000', '0000-00-00 00:00:00.000000', 0, 'yzquierdo@00000000', 'Maria Segunda Juana', 'Yzquierdo Huaman', 'null', 0, 1, '0000-00-00 00:00:00.000000', '00000001'),
(105, 'av@6251105', '0000-00-00 00:00:00.000000', 0, 'sanchez@6251105', 'Alejandro ', 'Sánchez Vera', 'null', 0, 1, '0000-00-00 00:00:00.000000', '06251105'),
(106, 'jp@41157915', '0000-00-00 00:00:00.000000', 0, 'sanchez@41157915', 'Joel Aldemar ', 'Sánchez Paredes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '41157915'),
(107, 'sv@19331071', '0000-00-00 00:00:00.000000', 0, 'rojas@19331071', 'Segundo David ', 'Rojas Vasquez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19331071'),
(108, 'fp@19328773', '0000-00-00 00:00:00.000000', 0, 'muñoz@19328773', 'Felicitas', 'Muñoz Pinedo', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19328773'),
(109, 'mm@1815f676', '0000-00-00 00:00:00.000000', 0, 'lezama@1815f676', 'Marta Asunción ', 'Lezama Mendoza', 'null', 0, 1, '0000-00-00 00:00:00.000000', '18158676'),
(110, 'cd@19328782', '0000-00-00 00:00:00.000000', 0, 'tirado@19328782', 'Caytano ', 'Tirado Durand', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19328782'),
(111, 'mr@40869212', '0000-00-00 00:00:00.000000', 0, 'gutierrez@40869212', 'Manira Lisette ', 'Gutierrez Rivasplata', 'null', 0, 1, '0000-00-00 00:00:00.000000', '40869212'),
(112, 'vr@70524730', '0000-00-00 00:00:00.000000', 0, 'gutierrez@70524730', 'Valeria ', 'Gutierrez Rivasplata', 'null', 0, 1, '0000-00-00 00:00:00.000000', '70524730'),
(113, 'je@08187055', '0000-00-00 00:00:00.000000', 0, 'gutierrez@08187055', 'Jorge Amado ', 'Gutierrez Esaine', 'null', 0, 1, '0000-00-00 00:00:00.000000', '08187055'),
(114, 'cl@42965616', '0000-00-00 00:00:00.000000', 0, 'cotrina@42965616', 'Christian Javier ', 'Cotrina Lezama', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42965616'),
(115, 'lr@41907802', '0000-00-00 00:00:00.000000', 0, 'deza@41907802', 'Lucia Pastora ', 'Deza Rodríguez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '41907802'),
(116, 'cp@27911329', '0000-00-00 00:00:00.000000', 0, 'sanchez@27911329', 'Corpus Mercedes ', 'Sánchez Paredes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27911329'),
(117, 'hs@40353504', '0000-00-00 00:00:00.000000', 0, 'castañeda@40353504', 'Henry Wllfredo ', 'Castañeda Sánchez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '40353504'),
(118, 'sp@27911328', '0000-00-00 00:00:00.000000', 0, 'castañeda@27911328', 'Segundo Wllfredo ', 'Castañeda Paredes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27911328'),
(119, 'jv@27916045', '0000-00-00 00:00:00.000000', 0, 'valderrama@27916045', 'José Elíseo ', 'Valderrama Vargas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27916045'),
(120, 'jp@26667183', '0000-00-00 00:00:00.000000', 0, 'alias@26667183', 'José Melquíades ', 'Alias Pastor', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26667183'),
(121, 'mr@18866339', '0000-00-00 00:00:00.000000', 0, 'medina@18866339', 'Maria Esperanza ', 'Medina Rojas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '18866339'),
(122, 'fm@42772161', '0000-00-00 00:00:00.000000', 0, 'paredes@42772161', 'Francisco Apolinar ', 'Paredes Medina', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42772161'),
(123, 'dm@26667585', '0000-00-00 00:00:00.000000', 0, 'muñoz@26667585', 'Diomedes ', 'Muñoz Machuca', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26667585'),
(124, 'db@27901888', '0000-00-00 00:00:00.000000', 0, 'vargas@27901888', 'Domiclano ', 'Vargas Burgos', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27901888'),
(125, 'ms@27910890', '0000-00-00 00:00:00.000000', 0, 'rabanal@27910890', 'Manuel Valentin ', 'Rabanal Sánchez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27910890'),
(126, 'ju@26625797', '0000-00-00 00:00:00.000000', 0, 'tirado@26625797', 'José Quirino ', 'Tirado Urbina', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26625797'),
(127, 'jr@43218123', '0000-00-00 00:00:00.000000', 0, 'tirado@43218123', 'José Luis ', 'Tirado Ríos', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43218123'),
(128, 'ec@43476300', '0000-00-00 00:00:00.000000', 0, 'jara@43476300', 'Ernesto', 'Jara Choroco', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43476300'),
(129, 'rc@43497168', '0000-00-00 00:00:00.000000', 0, 'culqui@43497168', 'Rubén Leonardo ', 'Culqui Chunqui', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43497168'),
(130, 'po@41917146', '0000-00-00 00:00:00.000000', 0, 'rabines@41917146', 'Pedro Miguel ', 'Rabines Olortegui', 'null', 0, 1, '0000-00-00 00:00:00.000000', '41917146'),
(131, 'ds@19320491', '0000-00-00 00:00:00.000000', 0, 'castañeda@19320491', 'Dora Alvina ', 'Castañeda Suarez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19320491'),
(132, 'am@44791210', '0000-00-00 00:00:00.000000', 0, 'linares@44791210', 'Alan Rodin ', 'Linares Mendoza', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44791210'),
(133, 'jc@44306833', '0000-00-00 00:00:00.000000', 0, 'la@44306833', 'Juan de ', 'la Cruz Ramírez Bueno', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44306833'),
(134, 'aa@27926202', '0000-00-00 00:00:00.000000', 0, 'pastor@27926202', 'Agustín ', 'Pastor Abanto', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27926202'),
(135, 'so@40252939', '0000-00-00 00:00:00.000000', 0, 'cotrina@40252939', 'Segundo Raúl ', 'Cotrina Olortegui', 'null', 0, 1, '0000-00-00 00:00:00.000000', '40252939'),
(136, 'sa@26923105', '0000-00-00 00:00:00.000000', 0, 'moreno@26923105', 'Sixto Doroteo ', 'Moreno Avalos', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26923105'),
(137, 'jc@179109Ú9', '0000-00-00 00:00:00.000000', 0, 'abanto@17910919', 'José Germán ', 'Abanto Crespin', 'null', 0, 1, '0000-00-00 00:00:00.000000', '17910919'),
(138, 'qd@27901015', '0000-00-00 00:00:00.000000', 0, 'rojas@27901015', 'Quiteria Elena ', 'Rojas de Briones', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27901015'),
(139, 'mb@00000000', '0000-00-00 00:00:00.000000', 0, 'cieza@00000000', 'Mara Jazmin ', 'Cieza Briones', 'null', 0, 1, '0000-00-00 00:00:00.000000', '00000002'),
(140, 'mc@19216567', '0000-00-00 00:00:00.000000', 0, 'paz@19216567', 'María Beldad ', 'Paz Cruzado', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19216567'),
(141, 'wa@44089836', '0000-00-00 00:00:00.000000', 0, 'morales@44089836', 'Wilmer ', 'Morales Arrelucea', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44089836'),
(142, 'sm@27911005', '0000-00-00 00:00:00.000000', 0, 'ruiz@27911005', 'Segundo ', 'Ruiz Meléndez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27911005'),
(143, 'cv@43015053', '0000-00-00 00:00:00.000000', 0, 'mejia@43015053', 'César Danny ', 'Mejía Vásquez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43015053'),
(144, 'aj@47256724', '0000-00-00 00:00:00.000000', 0, 'garda@47256724', 'Agustín ', 'Garda Jara', 'null', 0, 1, '0000-00-00 00:00:00.000000', '47256724'),
(145, 'lc@26701199', '0000-00-00 00:00:00.000000', 0, 'flores@26701199', 'Luis ', 'Flores Chuquiruna', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26701199'),
(146, 'pg@26699572', '0000-00-00 00:00:00.000000', 0, 'rabanal@26699572', 'Primitivo ', 'Rabanal Guerra', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26699572'),
(147, 'jr@41429546', '0000-00-00 00:00:00.000000', 0, 'cerdan@41429546', 'José Cruz ', 'Cerdán Ríos', 'null', 0, 1, '0000-00-00 00:00:00.000000', '41429546'),
(148, 'la@42929678', '0000-00-00 00:00:00.000000', 0, 'novoa@42929678', 'Leoncio ', 'Novoa Arias', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42929678'),
(149, 'rm@43821528', '0000-00-00 00:00:00.000000', 0, 'tirado@43821528', 'Rosendo ', 'Tirado Medrano', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43821528'),
(150, 'bm@45377324', '0000-00-00 00:00:00.000000', 0, 'arias@45377324', 'Bladimir Ernerzon ', 'Arias Machuca', 'null', 0, 1, '0000-00-00 00:00:00.000000', '45377324'),
(151, 'em@27926996', '0000-00-00 00:00:00.000000', 0, 'rios@27926996', 'Elias ', 'Ríos Marín', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27926996'),
(152, 'ja@46970061', '0000-00-00 00:00:00.000000', 0, 'novoa@46970061', 'José Demerio ', 'Novoa Arias', 'null', 0, 1, '0000-00-00 00:00:00.000000', '46970061'),
(153, 'jl@10477468', '0000-00-00 00:00:00.000000', 0, 'sanchez@10477468', 'José Luis ', 'Sánchez Licera', 'null', 0, 1, '0000-00-00 00:00:00.000000', '10477468'),
(154, 'rv@27905888', '0000-00-00 00:00:00.000000', 0, 'castañeda@27905888', 'Rosel ', 'Castañeda Valera', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27905888'),
(155, 'ar@42877693', '0000-00-00 00:00:00.000000', 0, 'silva@42877693', 'Abel ', 'Silva Rojas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42877693'),
(156, 'ib@44406126', '0000-00-00 00:00:00.000000', 0, 'abanto@44406126', 'Ingrid Smith ', 'Abanto Becerra', 'null', 0, 1, '0000-00-00 00:00:00.000000', '44406126'),
(157, 'nd@27926267', '0000-00-00 00:00:00.000000', 0, 'marin@27926267', 'Napoleon ', 'Marán Dávila', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27926267'),
(158, 'jq@27903180', '0000-00-00 00:00:00.000000', 0, 'cabrera@27903180', 'José Juan ', 'Cabrera Quiroz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27903180'),
(159, 'rr@17887991', '0000-00-00 00:00:00.000000', 0, 'zare@17887991', 'Rosa Mercedes ', 'Zare Reyes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '17887991'),
(160, 'jp@00000000', '0000-00-00 00:00:00.000000', 0, 'sanchez@00000000', 'José Miguel ', 'Sánchez Perez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '00000003'),
(161, 'gs@19201895', '0000-00-00 00:00:00.000000', 0, 'castañeda@19201895', 'Gonzalo ', 'Castañeda Suarez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19201895'),
(162, 'ab@26926326', '0000-00-00 00:00:00.000000', 0, 'barrantes@26926326', 'Adrián ', 'Barrantes Blas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26926326'),
(165, 'pg@27911205', '0000-00-00 00:00:00.000000', 0, 'melendez@27911205', 'Pedro Agapito ', 'Melendez Gonzales', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27911205'),
(166, 'jh@27920687', '0000-00-00 00:00:00.000000', 0, 'quiroz@27920687', 'José Ceferino ', 'Quiroz Huaman', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27920687'),
(167, 'ec@27913517', '0000-00-00 00:00:00.000000', 0, 'marin@27913517', 'Eusebia Maruja ', 'Marán Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27913517'),
(168, 'ms@45717942', '0000-00-00 00:00:00.000000', 0, 'castañeda@45717942', 'María Delisbeth ', 'Castañeda Sánchez', 'null', 0, 1, '0000-00-00 00:00:00.000000', '45717942'),
(169, 'si@42807858', '0000-00-00 00:00:00.000000', 0, 'carrera@42807858', 'Santos Elmer ', 'Carrera Izquierdo', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42807858'),
(170, 'sd@27913458', '0000-00-00 00:00:00.000000', 0, 'medina@27913458', 'Sara Mercedes ', 'Medina de Aguilar', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27913458'),
(171, 'jt@27901910', '0000-00-00 00:00:00.000000', 0, 'sanchez@27901910', 'José Alejandro ', 'Sánchez Torres', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27901910'),
(172, 'jt@27926927', '0000-00-00 00:00:00.000000', 0, 'rojas@27926927', 'José Jesús ', 'Rojas Tirado', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27926927'),
(173, 'mm@41212545', '0000-00-00 00:00:00.000000', 0, 'tirado@41212545', 'Maria Eulalia ', 'Tirado Muñoz', 'null', 0, 1, '0000-00-00 00:00:00.000000', '41212545'),
(174, 'jm@27927033', '0000-00-00 00:00:00.000000', 0, 'cabanlllas@27927033', 'José Arcadio ', 'Cabanlllas Moreno', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27927033'),
(175, 'sc@27929210', '0000-00-00 00:00:00.000000', 0, 'sanchez@27929210', 'Santos Percy ', 'Sánchez Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27929210'),
(176, 'mr@25441298', '0000-00-00 00:00:00.000000', 0, 'valera@25441298', 'María Lidia ', 'Valera Rojas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '25441298'),
(177, 'yd@42968280', '0000-00-00 00:00:00.000000', 0, 'vasquez@42968280', 'Yencarlos ', 'Vásquez Delgado', 'null', 0, 1, '0000-00-00 00:00:00.000000', '42968280'),
(178, 'dc@46554129', '0000-00-00 00:00:00.000000', 0, 'tirado@46554129', 'Diomelis ', 'Tirado Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '46554129'),
(179, 'lt@19205161', '0000-00-00 00:00:00.000000', 0, 'eugenio@19205161', 'Luda ', 'Eugenio Tocas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19205161'),
(180, 'fp@27904785', '0000-00-00 00:00:00.000000', 0, 'machuca@27904785', 'Florentino ', 'Machuca Paredes', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27904785'),
(181, 'jm@27913696', '0000-00-00 00:00:00.000000', 0, 'lezama@27913696', 'José María ', 'Lezama Mendoza', 'null', 0, 1, '0000-00-00 00:00:00.000000', '27913696'),
(182, 'fc@19240928', '0000-00-00 00:00:00.000000', 0, 'ayay@19240928', 'Felipe Pascual ', 'Ayay Carrasco', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19240928'),
(183, 'mv@00000000', '0000-00-00 00:00:00.000000', 0, 'izquierdo@00000000', 'Maria Santana ', 'Izquierdo Velezmoro', 'null', 0, 1, '0000-00-00 00:00:00.000000', '00000006'),
(184, 'sq@41711178', '0000-00-00 00:00:00.000000', 0, 'quipe@41711178', 'Santiago ', 'QuispeTello', 'null', 0, 1, '0000-00-00 00:00:00.000000', '41711178'),
(185, 'ja@74357312', '0000-00-00 00:00:00.000000', 0, 'flores@74357312', 'José Ivan ', 'Flores Abanto', 'null', 0, 1, '0000-00-00 00:00:00.000000', '74357312'),
(186, 'lm@43722068', '0000-00-00 00:00:00.000000', 0, 'arias@43722068', 'Ludim Melquesidec ', 'Arias Machuca', 'null', 0, 1, '0000-00-00 00:00:00.000000', '43722068'),
(187, 'mc@80038061', '0000-00-00 00:00:00.000000', 0, 'abanto@80038061', 'Maria Mercedes ', 'Abanto Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '80038061'),
(188, 'fm@40391027', '0000-00-00 00:00:00.000000', 0, 'muñoz@40391027', 'Felicita Guísela ', 'Muñoz Machuca', 'null', 0, 1, '0000-00-00 00:00:00.000000', '40391027'),
(189, 'mc@41697257', '0000-00-00 00:00:00.000000', 0, 'rios@41697257', 'Maximiliano ', 'Rios Calderón', 'null', 0, 1, '0000-00-00 00:00:00.000000', '41697257'),
(190, 'pm@46743454', '0000-00-00 00:00:00.000000', 0, 'karin@46743454', 'Pamela Yovanna ', 'Karin Muñoz Soto', 'null', 0, 1, '0000-00-00 00:00:00.000000', '46743454'),
(191, 'jb@19332504', '0000-00-00 00:00:00.000000', 0, 'becerra@19332504', 'José', 'Becerra Beyodas', 'null', 0, 1, '0000-00-00 00:00:00.000000', '19332504'),
(192, 'aq@26922504', '0000-00-00 00:00:00.000000', 0, 'galarreta@26922504', 'Américo Inocente ', 'Galarreta Quesada', 'null', 0, 1, '0000-00-00 00:00:00.000000', '26922504'),
(193, 'ra@46546249', '0000-00-00 00:00:00.000000', 0, 'novoa@46546249', 'Renán ', 'Novoa Arias', 'null', 0, 1, '0000-00-00 00:00:00.000000', '46546249'),
(194, 'jc@40633699', '0000-00-00 00:00:00.000000', 0, 'honorio@40633699', 'Juan Robert ', 'Honorio Castañeda', 'null', 0, 1, '0000-00-00 00:00:00.000000', '40633699');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_user_groups`
--

CREATE TABLE `auth_user_groups` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auth_user_user_permissions`
--

CREATE TABLE `auth_user_user_permissions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `auth_user_user_permissions`
--

INSERT INTO `auth_user_user_permissions` (`id`, `user_id`, `permission_id`) VALUES
(2, 2, 137),
(1, 3, 138);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `canal`
--

CREATE TABLE `canal` (
  `id_canal` int(11) NOT NULL,
  `nombre` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `tamano` double DEFAULT NULL,
  `ubicacion` varchar(45) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `canal`
--

INSERT INTO `canal` (`id_canal`, `nombre`, `tamano`, `ubicacion`) VALUES
(1, 'Ramal 1', 2, 'Canal Madre'),
(2, 'Ramal 2', 4, 'Continuación del canal madre'),
(3, 'Ramal 3', 1.8, 'Canal Madre'),
(4, 'Ramal 4', 3.1, 'parte del ramal 3'),
(5, 'Ramal 5', 1.2, 'parte del ramal 3');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caudal`
--

CREATE TABLE `caudal` (
  `id_caudal` int(11) NOT NULL,
  `id_canal` int(11) DEFAULT NULL,
  `fecha` datetime DEFAULT NULL,
  `nivel` int(11) DEFAULT NULL,
  `descripcion` varchar(45) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `caudal`
--

INSERT INTO `caudal` (`id_caudal`, `id_canal`, `fecha`, `nivel`, `descripcion`) VALUES
(1, 1, '2019-08-01 00:00:00', 6, 'Descripción'),
(2, 2, '2019-08-01 00:00:00', 3, 'Descripción'),
(3, 3, '2019-08-01 00:00:00', 4, 'Descripción'),
(4, 4, '2019-08-01 00:00:00', 1, 'Descripción'),
(5, 5, '2019-08-01 00:00:00', 1, 'Descripción'),
(6, 1, '2019-08-02 00:00:00', 5, 'Descripción'),
(7, 2, '2019-08-02 00:00:00', 2, 'Descripción'),
(8, 3, '2019-08-02 00:00:00', 5, 'Descripción'),
(9, 4, '2019-08-02 00:00:00', 4, 'Descripción'),
(10, 5, '2019-08-02 00:00:00', 5, 'Descripción');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comite`
--

CREATE TABLE `comite` (
  `id_comite` int(11) NOT NULL,
  `nombre` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `descripcion` varchar(200) COLLATE hp8_bin DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comprobante`
--

CREATE TABLE `comprobante` (
  `id_comprobante` int(11) NOT NULL,
  `id_talonario` int(11) NOT NULL,
  `ticket_numero` int(11) DEFAULT NULL,
  `concepto` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `tipo` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `monto` double DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comp_multa`
--

CREATE TABLE `comp_multa` (
  `id_comp_multa` int(11) NOT NULL,
  `id_comprobante` int(11) NOT NULL,
  `id_multa` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `comp_orden`
--

CREATE TABLE `comp_orden` (
  `id_comp_orden` int(11) NOT NULL,
  `id_comprobante` int(11) NOT NULL,
  `id_orden` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `datos_personales`
--

CREATE TABLE `datos_personales` (
  `id_datos_personales` int(11) NOT NULL,
  `dni` char(8) COLLATE hp8_bin DEFAULT NULL,
  `alias` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `sexo` char(1) COLLATE hp8_bin DEFAULT NULL,
  `fecha_nacimiento` date DEFAULT NULL,
  `telefono` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `celular` char(13) COLLATE hp8_bin DEFAULT NULL,
  `foto` varchar(150) COLLATE hp8_bin DEFAULT NULL,
  `id_auth_user` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `datos_personales`
--

INSERT INTO `datos_personales` (`id_datos_personales`, `dni`, `alias`, `sexo`, `fecha_nacimiento`, `telefono`, `celular`, `foto`, `id_auth_user`) VALUES
(1, '76583884', 'Nene', 'M', '1994-11-30', NULL, '927088981', 'photos/20180508_165334.jpg', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `destajo`
--

CREATE TABLE `destajo` (
  `id_destajo` int(11) NOT NULL,
  `id_canal` int(11) DEFAULT NULL,
  `id_parcela` int(11) DEFAULT NULL,
  `tamano` double DEFAULT NULL,
  `num_orden` int(11) DEFAULT NULL,
  `fecha_registro` date DEFAULT NULL,
  `descripcion` varchar(45) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `det_asamb_canal`
--

CREATE TABLE `det_asamb_canal` (
  `id_dt_asmb_canal` int(11) NOT NULL,
  `id_asamblea` int(11) DEFAULT NULL,
  `id_canal` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Volcado de datos para la tabla `det_asamb_canal`
--

INSERT INTO `det_asamb_canal` (`id_dt_asmb_canal`, `id_asamblea`, `id_canal`) VALUES
(16, 62, 3),
(19, 65, 3),
(22, 68, 4);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `det_limpieza`
--

CREATE TABLE `det_limpieza` (
  `id_det_limpieza` int(11) NOT NULL,
  `id_destajo` int(11) DEFAULT NULL,
  `id_limpieza` int(11) DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `fecha` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `det_lista`
--

CREATE TABLE `det_lista` (
  `id_det_lista` int(11) NOT NULL,
  `id_lista` int(11) DEFAULT NULL,
  `id_auth_user` int(11) DEFAULT NULL,
  `cargo` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `direccion`
--

CREATE TABLE `direccion` (
  `id_direccion` int(11) NOT NULL,
  `id_datos_personales` int(11) DEFAULT NULL,
  `pais` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `cod_postal` int(11) DEFAULT NULL,
  `departamento` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `provinciaa` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `distrito` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `dir_larga` varchar(100) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_admin_log`
--

CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext COLLATE hp8_bin,
  `object_repr` varchar(200) COLLATE hp8_bin NOT NULL,
  `action_flag` smallint(5) UNSIGNED NOT NULL,
  `change_message` longtext COLLATE hp8_bin NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `django_admin_log`
--

INSERT INTO `django_admin_log` (`id`, `action_time`, `object_id`, `object_repr`, `action_flag`, `change_message`, `content_type_id`, `user_id`) VALUES
(1, '2018-10-24 14:00:45.888346', '3', 'Canalero', 2, '[{\"changed\": {\"fields\": [\"user_permissions\"]}}]', 4, 1),
(2, '2018-10-24 14:00:56.459897', '2', 'Presidente', 2, '[{\"changed\": {\"fields\": [\"user_permissions\"]}}]', 4, 1),
(3, '2018-10-27 03:58:43.027307', '9', 'Shando', 3, '', 4, 1),
(4, '2018-11-09 00:07:50.198552', '11', 'Geral', 3, '', 4, 1),
(5, '2018-11-09 00:07:50.241524', '6', 'Gerardo', 3, '', 4, 1),
(6, '2018-11-09 00:07:50.298626', '12', 'Maria', 3, '', 4, 1),
(7, '2018-11-09 00:07:50.357250', '8', 'Mario', 3, '', 4, 1),
(8, '2018-11-09 00:07:50.379190', '7', 'Micaela', 3, '', 4, 1),
(9, '2018-11-09 00:07:50.390657', '10', 'Shando', 3, '', 4, 1),
(10, '2018-11-09 00:07:50.401338', '4', 'Tany', 3, '', 4, 1),
(11, '2018-11-09 00:13:39.848561', '11', 'Geral', 3, '', 4, 1),
(12, '2018-11-09 00:13:39.915356', '6', 'Gerardo', 3, '', 4, 1),
(13, '2018-11-09 00:13:39.927295', '12', 'Maria', 3, '', 4, 1),
(14, '2018-11-09 00:13:39.956216', '8', 'Mario', 3, '', 4, 1),
(15, '2018-11-09 00:13:40.048968', '7', 'Micaela', 3, '', 4, 1),
(16, '2018-11-09 00:13:40.059939', '10', 'Shando', 3, '', 4, 1),
(17, '2018-11-09 00:13:40.081880', '4', 'Tany', 3, '', 4, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_content_type`
--

CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL,
  `app_label` varchar(100) COLLATE hp8_bin NOT NULL,
  `model` varchar(100) COLLATE hp8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `django_content_type`
--

INSERT INTO `django_content_type` (`id`, `app_label`, `model`) VALUES
(1, 'admin', 'logentry'),
(3, 'auth', 'group'),
(2, 'auth', 'permission'),
(4, 'auth', 'user'),
(5, 'contenttypes', 'contenttype'),
(7, 'inicio', 'acceso'),
(29, 'inicio', 'agendaasamblea'),
(30, 'inicio', 'archivosparcela'),
(8, 'inicio', 'asamblea'),
(9, 'inicio', 'asistencia'),
(31, 'inicio', 'authgroup'),
(32, 'inicio', 'authgrouppermissions'),
(33, 'inicio', 'authpermission'),
(34, 'inicio', 'authuser'),
(35, 'inicio', 'authusergroups'),
(36, 'inicio', 'authuseruserpermissions'),
(10, 'inicio', 'canal'),
(11, 'inicio', 'caudal'),
(12, 'inicio', 'comite'),
(43, 'inicio', 'compmulta'),
(44, 'inicio', 'comporden'),
(13, 'inicio', 'comprobante'),
(37, 'inicio', 'datospersonales'),
(14, 'inicio', 'destajo'),
(48, 'inicio', 'detasambcanal'),
(15, 'inicio', 'detlimpieza'),
(16, 'inicio', 'detlista'),
(17, 'inicio', 'direccion'),
(38, 'inicio', 'djangoadminlog'),
(39, 'inicio', 'djangocontenttype'),
(40, 'inicio', 'djangomigrations'),
(41, 'inicio', 'djangosession'),
(42, 'inicio', 'hojaasistencia'),
(18, 'inicio', 'limpieza'),
(19, 'inicio', 'lista'),
(20, 'inicio', 'multa'),
(45, 'inicio', 'multaasistencia'),
(46, 'inicio', 'multalimpia'),
(47, 'inicio', 'multaorden'),
(21, 'inicio', 'noticia'),
(22, 'inicio', 'obra'),
(23, 'inicio', 'ordenriego'),
(24, 'inicio', 'parcela'),
(25, 'inicio', 'persona'),
(26, 'inicio', 'reparto'),
(27, 'inicio', 'talonario'),
(28, 'inicio', 'usuario'),
(6, 'sessions', 'session');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_migrations`
--

CREATE TABLE `django_migrations` (
  `id` int(11) NOT NULL,
  `app` varchar(255) COLLATE hp8_bin NOT NULL,
  `name` varchar(255) COLLATE hp8_bin NOT NULL,
  `applied` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `django_migrations`
--

INSERT INTO `django_migrations` (`id`, `app`, `name`, `applied`) VALUES
(1, 'contenttypes', '0001_initial', '2018-10-24 13:25:42.787826'),
(2, 'auth', '0001_initial', '2018-10-24 13:25:50.201390'),
(3, 'admin', '0001_initial', '2018-10-24 13:25:51.904184'),
(4, 'admin', '0002_logentry_remove_auto_add', '2018-10-24 13:25:51.967732'),
(5, 'admin', '0003_logentry_add_action_flag_choices', '2018-10-24 13:25:52.049807'),
(6, 'contenttypes', '0002_remove_content_type_name', '2018-10-24 13:25:52.803253'),
(7, 'auth', '0002_alter_permission_name_max_length', '2018-10-24 13:25:53.531835'),
(8, 'auth', '0003_alter_user_email_max_length', '2018-10-24 13:25:54.222407'),
(9, 'auth', '0004_alter_user_username_opts', '2018-10-24 13:25:54.320867'),
(10, 'auth', '0005_alter_user_last_login_null', '2018-10-24 13:25:54.892151'),
(11, 'auth', '0006_require_contenttypes_0002', '2018-10-24 13:25:54.941310'),
(12, 'auth', '0007_alter_validators_add_error_messages', '2018-10-24 13:25:55.004515'),
(13, 'auth', '0008_alter_user_username_max_length', '2018-10-24 13:25:55.554831'),
(14, 'auth', '0009_alter_user_last_name_max_length', '2018-10-24 13:25:56.145624'),
(15, 'sessions', '0001_initial', '2018-10-24 13:25:57.080944'),
(16, 'usuario', '0001_initial', '2018-10-24 14:00:09.350040'),
(17, 'canalero', '0001_initial', '2018-10-24 14:00:09.634887'),
(18, 'usuario', '0002_auto_20180912_1116', '2018-10-24 14:00:12.077464'),
(19, 'usuario', '0003_parcela', '2018-10-24 14:00:13.002116'),
(20, 'usuario', '0004_auto_20181011_1038', '2018-10-24 14:00:14.532277'),
(21, 'canalero', '0002_delete_reparto', '2018-10-24 14:00:14.877007'),
(22, 'inicio', '0001_initial', '2018-10-24 14:00:15.074979'),
(23, 'inicio', '0002_agendaasamblea_archivosparcela_authgroup_authgrouppermissions_authpermission_authuser_authusergroups', '2018-10-24 14:00:15.189204'),
(24, 'inicio', '0003_auto_20181017_1014', '2018-10-24 14:00:15.207290'),
(25, 'inicio', '0004_auto_20181017_1453', '2018-10-24 14:00:15.228086'),
(26, 'inicio', '0005_compmulta_comporden_multaasistencia_multalimpia_multaorden', '2018-10-24 22:39:18.896977'),
(27, 'auth', '0010_alter_group_name_max_length', '2019-07-28 07:35:21.456010'),
(28, 'auth', '0011_update_proxy_permissions', '2019-07-28 07:35:21.542846'),
(29, 'inicio', '0006_auto_20190728_0233', '2019-07-28 07:35:21.571745');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `django_session`
--

CREATE TABLE `django_session` (
  `session_key` varchar(40) COLLATE hp8_bin NOT NULL,
  `session_data` longtext COLLATE hp8_bin NOT NULL,
  `expire_date` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `django_session`
--

INSERT INTO `django_session` (`session_key`, `session_data`, `expire_date`) VALUES
('0xk1uu0e42vois7na5d5wfcvi3x11vsy', 'Y2MyNmYzOWVmOThiMDU3NDJiMzBlZjE0MTMzOTA5MjBhMmMyNGNjMzp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJkMmZkM2I0OGM1NGQwZjk4ZDcxZmM0YjUyZmE0ODc2M2UxNTY3MTkwIn0=', '2019-08-20 04:39:46.711525'),
('1ccvzwq4pslk9ndabwh2f7hvfsndob8i', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 20:35:58.926615'),
('1y5l67o1fmpxhaikumu5qj6r6mr2vmmp', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-02-28 00:53:35.679803'),
('3ynq9lanaqjfyvonmelghvsibh217o4u', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 05:55:23.754279'),
('3zseb4leg8pxordnbotypm5mmzyzl95q', 'Y2MyNmYzOWVmOThiMDU3NDJiMzBlZjE0MTMzOTA5MjBhMmMyNGNjMzp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJkMmZkM2I0OGM1NGQwZjk4ZDcxZmM0YjUyZmE0ODc2M2UxNTY3MTkwIn0=', '2019-08-15 03:09:49.811102'),
('4da8kkkeky53mglf3i0spz7r84ku3ts7', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2018-12-19 04:52:01.362211'),
('4fzqoitfrcwiylye5rs88fuwa6nsq0yf', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 01:34:12.307928'),
('4hsrjhngfddtsab470dt96a9moihr8x8', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:17:14.954273'),
('5t85ym829tstif20vlq49btj6aifvnpw', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2018-11-28 03:37:10.599686'),
('614iv2rnzoq295iiad7xb8ceek627zm5', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 06:04:09.693747'),
('61s69hw7qdu0788eefpxo08obzg3vg2d', 'Y2MyNmYzOWVmOThiMDU3NDJiMzBlZjE0MTMzOTA5MjBhMmMyNGNjMzp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJkMmZkM2I0OGM1NGQwZjk4ZDcxZmM0YjUyZmE0ODc2M2UxNTY3MTkwIn0=', '2019-08-11 01:53:00.245201'),
('65upvsxujm7t3y59qb7oxuew3ph1lbo4', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2018-12-19 04:47:26.986865'),
('6j921vm0alcg0wz2k08lpgi4p75gx1zm', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:32:40.030620'),
('75ckoeeh0w8vxzkgruxln3qlbt0788b5', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:13:34.211631'),
('7xqu9lccef9immkw1916gcpn2wq32p7e', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 20:45:29.740744'),
('8b5ngjr744ffw086fa7g60hvyqe5uvyz', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-02 02:35:43.897838'),
('aaw7rbb3gludd0shf70dppejvwrxvuin', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-03-23 03:07:20.731862'),
('asmv0z9zzrro17q0ukvl0em59gsdqjxe', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:15:10.598969'),
('avvx4stu9fbd0ya2e2edns6e8t1ycatf', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:04:39.247484'),
('b5w8bq7mc45ngk29ure7vbso5vja6gfg', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:12:34.787156'),
('bq9dq161ug15j8p9pnpc4zyxyqahbk6j', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-05-04 19:09:01.366379'),
('c56b5fzbkcobbiy105296r8twyq43w6o', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:12:16.006079'),
('cjotbhnry6ctyrecq5mhdkvrouczn0pw', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-16 16:32:36.082730'),
('clydvrz26t9rd03wltkflqjvh0nykwjc', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 14:17:19.304949'),
('d1p4cqa180eqzbgi4y5emxvwce9iw8zr', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2019-02-19 01:30:41.004640'),
('fjolhbix1iwfpn1byd21h7pwpkrklpek', 'ZjE4ZTg4OWVhMjc0MTg0NTUxMGU2YjcyZWZiZDk5MmYxYTE1NWMyNjp7fQ==', '2018-11-07 22:28:02.214088'),
('gece0q5sinynjff2gmhoc0baky6ffc1w', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:27:13.596974'),
('i13iymtpnpmegzvapg99zhed45fm5jpe', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-29 00:25:54.110431'),
('iu9ni74ux5u026buq34zrqu4496s34q6', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-07 08:56:02.424126'),
('ix0j23u5ds65tp49rrhzhf3rrp2ayn2k', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:29:59.709324'),
('j3z2icr2fi74lr9swt8oq3xbvxx0a5cv', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:14:33.993703'),
('jhzyryfgvvviiwrmz34vevhxxfyfpj1d', 'Y2MyNmYzOWVmOThiMDU3NDJiMzBlZjE0MTMzOTA5MjBhMmMyNGNjMzp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJkMmZkM2I0OGM1NGQwZjk4ZDcxZmM0YjUyZmE0ODc2M2UxNTY3MTkwIn0=', '2019-08-11 01:54:41.513171'),
('k2uddztpqog4kipts41tndo9owkn8af7', 'Y2MyNmYzOWVmOThiMDU3NDJiMzBlZjE0MTMzOTA5MjBhMmMyNGNjMzp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJkMmZkM2I0OGM1NGQwZjk4ZDcxZmM0YjUyZmE0ODc2M2UxNTY3MTkwIn0=', '2019-08-10 23:05:16.319172'),
('kmvgz3o5rioilblg3wwqur6im3o86ozb', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 04:51:24.185699'),
('ko7mvmbtj3tt39pcy9hg7l27dvfj21h7', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:28:05.671350'),
('kzhakshs3t1ks0d9r3h3qa7plsxkyuwj', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:30:11.007831'),
('l6zjj5grboiwadmdsr98lmf0ryn1a4p8', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:28:45.828260'),
('mlnbjat13hrgolefic8za87mpq271ga3', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 19:47:46.294384'),
('n1ksidqyjs1ojn327k9ixficft3jfjpq', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-06-16 06:34:28.934645'),
('n3hk15v3i4v5vtxkd5takriw0ln1yei4', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:32:08.020249'),
('npbcewt24ssfsgy5re407fv2hvsvkhe6', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:05:20.808965'),
('nqpnbnnbwtrt1plqgw5me8tw162qw6bg', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-05-04 18:54:58.265816'),
('nrbtckgzfon5yl65yp2nnvghzbjtgw5d', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2018-12-19 04:49:41.953863'),
('nuasrsi6kalukk6ot8uj1wlzcuj9qg8a', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:35:52.642609'),
('o4rv64adiy0olc6xlb77jinfzvut4olp', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-09 04:20:52.397983'),
('pezgbhr4pqyass4edmqhe4hgqphyl94x', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 13:50:51.058756'),
('pn30dgpr1dyvxpdziq7p8dav5gq8xqql', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:02:30.554228'),
('pwqlgtqlp8i2w2uav0oir40qs6mu8x1g', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2018-12-05 02:40:25.191997'),
('qmnqakzfrg49ye887g4ic3uwjc01gt9t', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:18:06.539177'),
('qsops7lej2cppuiaypoy1zo1en6n0umc', 'Y2MyNmYzOWVmOThiMDU3NDJiMzBlZjE0MTMzOTA5MjBhMmMyNGNjMzp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJkMmZkM2I0OGM1NGQwZjk4ZDcxZmM0YjUyZmE0ODc2M2UxNTY3MTkwIn0=', '2019-08-16 00:42:04.364950'),
('rw7m078dt8bnggmqtb6kepytsrufvj3u', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2019-02-18 01:24:21.106950'),
('s2vtchd00l4hocj4loortqkagthfp3qg', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:40:08.345137'),
('sfe6vpnm4vv1oatm5nnh6l0vb93cs9bm', 'MjExMTY5YTQ3MGViM2I3NTI5MmQ1YWMxYjZmYjIzZmRiMDkwYzZlMTp7Il9hdXRoX3VzZXJfaWQiOiIyIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI0OGUyYzk3Njg0ZmUzNjQ4YmE1NGVhYzEyNTEwODI4OWZhM2I0OGMxIn0=', '2019-02-20 02:26:10.705346'),
('tdxgz5nug9hyawlcb3rh8hhnhqyrat43', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 19:46:13.587812'),
('v4bbru1ugu74x6oihr7sk3cpdk3q9v7g', 'OTg3YmI5MzU5ZjJmM2RjOTIwMjYxZDU3MGIwMzUxNGYzYTQ2Mzk5MDp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiIzODUyYWEzZmViOTA4Mzg5YThmNTA4MmRkNzIyZWFmMWUzMzFlZGZmIn0=', '2019-02-17 23:58:57.924970'),
('vlugoy1p981fb3nxk2serk41onhsp199', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 05:45:57.261107'),
('wa7fjgv2og19w50m1ks7plh7cw3swj2n', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-28 23:00:43.880475'),
('xi764xzbb20hedqwt2jq2y0if3u8otdl', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 20:43:17.751521'),
('xqxbd573v0b1ikauesm824zhjf7zzwtm', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 19:50:35.934963'),
('yck1pt7iautzdlv9d8rdlwdsfzivaaqd', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:24:00.185875'),
('yxzljq9g20yh5fynbmr4ybsfutn3i80p', 'YjRlNTBkZjIyZmNjZDJmZjI0OTE3ZTdiNDYzOWQ5YzI2MzY2Y2I1Njp7Il9hdXRoX3VzZXJfaWQiOiIxIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiJhZDY2NTg3ZjhlODEyNmE0NGY3NDY1MWNlNjI1MjNmYmVlNmNjOWUxIn0=', '2019-07-27 00:21:48.663705'),
('zeqa0stzqx95gactvjjzkkrtq6wff3eh', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 16:27:04.594284'),
('zrcdlv9wu3elsgkxfl573ygsr145boo7', 'YmM3OWFhOTUwODhkZjY4ZjdjYzhlZGFkYTQ1MzNhZjY1NTBiOTAzZDp7Il9hdXRoX3VzZXJfaWQiOiIzIiwiX2F1dGhfdXNlcl9iYWNrZW5kIjoiZGphbmdvLmNvbnRyaWIuYXV0aC5iYWNrZW5kcy5Nb2RlbEJhY2tlbmQiLCJfYXV0aF91c2VyX2hhc2giOiI3ZDRmOTZhMzk3Nzc2NWZjZTcwYmJmNzYwZmZhZGE4MWQzNDdlMTI4In0=', '2018-11-17 05:24:10.834865');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `hoja_asistencia`
--

CREATE TABLE `hoja_asistencia` (
  `id_hoja_asistencia` int(11) NOT NULL,
  `id_asamblea` int(11) NOT NULL,
  `id_auth_user` int(11) NOT NULL,
  `estado` varchar(15) COLLATE hp8_bin NOT NULL,
  `hora` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `hoja_asistencia`
--

INSERT INTO `hoja_asistencia` (`id_hoja_asistencia`, `id_asamblea`, `id_auth_user`, `estado`, `hora`) VALUES
(5012, 62, 109, '3', '2019-08-03 01:30:42'),
(5013, 62, 110, '3', '2019-08-03 01:30:43'),
(5014, 62, 111, '3', '2019-08-03 01:30:43'),
(5015, 62, 113, '3', '2019-08-03 01:30:44'),
(5016, 62, 112, '3', '2019-08-03 01:30:44'),
(5017, 62, 114, '3', '2019-08-03 01:30:45'),
(5018, 62, 115, '3', '2019-08-03 01:30:45'),
(5019, 62, 35, '3', '2019-08-03 01:30:46'),
(5020, 62, 57, '3', '2019-08-03 01:30:46'),
(5021, 62, 116, '3', '2019-08-03 01:30:47'),
(5022, 62, 117, '1', '2000-12-12 12:00:00'),
(5023, 62, 108, '1', '2000-12-12 12:00:00'),
(5024, 62, 118, '1', '2000-12-12 12:00:00'),
(5025, 62, 119, '1', '2000-12-12 12:00:00'),
(5026, 62, 120, '1', '2000-12-12 12:00:00'),
(5027, 62, 121, '1', '2000-12-12 12:00:00'),
(5028, 62, 122, '1', '2000-12-12 12:00:00'),
(5029, 62, 123, '1', '2000-12-12 12:00:00'),
(5030, 62, 124, '1', '2000-12-12 12:00:00'),
(5031, 62, 125, '1', '2000-12-12 12:00:00'),
(5032, 62, 126, '1', '2000-12-12 12:00:00'),
(5033, 62, 127, '1', '2000-12-12 12:00:00'),
(5034, 62, 128, '1', '2000-12-12 12:00:00'),
(5035, 62, 129, '1', '2000-12-12 12:00:00'),
(5036, 62, 130, '1', '2000-12-12 12:00:00'),
(5037, 62, 131, '1', '2000-12-12 12:00:00'),
(5038, 62, 132, '1', '2000-12-12 12:00:00'),
(5039, 62, 133, '1', '2000-12-12 12:00:00'),
(5040, 62, 134, '1', '2000-12-12 12:00:00'),
(5041, 62, 135, '1', '2000-12-12 12:00:00'),
(5042, 62, 136, '1', '2000-12-12 12:00:00'),
(5043, 62, 137, '1', '2000-12-12 12:00:00'),
(5044, 62, 138, '1', '2000-12-12 12:00:00'),
(5045, 62, 139, '1', '2000-12-12 12:00:00'),
(5046, 62, 91, '1', '2000-12-12 12:00:00'),
(5047, 62, 140, '1', '2000-12-12 12:00:00'),
(5048, 62, 141, '1', '2000-12-12 12:00:00'),
(5049, 62, 142, '1', '2000-12-12 12:00:00'),
(5050, 62, 143, '1', '2000-12-12 12:00:00'),
(5051, 62, 144, '1', '2000-12-12 12:00:00'),
(5052, 62, 145, '1', '2000-12-12 12:00:00'),
(5053, 62, 146, '1', '2000-12-12 12:00:00'),
(5054, 62, 147, '1', '2000-12-12 12:00:00'),
(5055, 62, 148, '1', '2000-12-12 12:00:00'),
(5056, 62, 149, '3', '2000-12-12 12:00:00'),
(5057, 62, 46, '1', '2000-12-12 12:00:00'),
(5058, 62, 150, '1', '2000-12-12 12:00:00'),
(5059, 62, 151, '1', '2000-12-12 12:00:00'),
(5060, 62, 152, '1', '2000-12-12 12:00:00'),
(5061, 62, 105, '2', '2000-12-12 12:00:00'),
(5062, 62, 153, '1', '2000-12-12 12:00:00'),
(5063, 62, 154, '1', '2000-12-12 12:00:00'),
(5064, 62, 155, '1', '2000-12-12 12:00:00'),
(5065, 62, 156, '1', '2000-12-12 12:00:00'),
(5066, 62, 157, '1', '2000-12-12 12:00:00'),
(5185, 65, 109, '3', '2000-12-12 12:00:00'),
(5186, 65, 110, '1', '2000-12-12 12:00:00'),
(5187, 65, 111, '1', '2000-12-12 12:00:00'),
(5188, 65, 113, '1', '2000-12-12 12:00:00'),
(5189, 65, 112, '1', '2000-12-12 12:00:00'),
(5190, 65, 114, '1', '2000-12-12 12:00:00'),
(5191, 65, 115, '1', '2000-12-12 12:00:00'),
(5192, 65, 35, '1', '2000-12-12 12:00:00'),
(5193, 65, 57, '1', '2000-12-12 12:00:00'),
(5194, 65, 116, '1', '2000-12-12 12:00:00'),
(5195, 65, 117, '1', '2000-12-12 12:00:00'),
(5196, 65, 108, '1', '2000-12-12 12:00:00'),
(5197, 65, 118, '1', '2000-12-12 12:00:00'),
(5198, 65, 119, '1', '2000-12-12 12:00:00'),
(5199, 65, 120, '1', '2000-12-12 12:00:00'),
(5200, 65, 121, '1', '2000-12-12 12:00:00'),
(5201, 65, 122, '1', '2000-12-12 12:00:00'),
(5202, 65, 123, '1', '2000-12-12 12:00:00'),
(5203, 65, 124, '1', '2000-12-12 12:00:00'),
(5204, 65, 125, '1', '2000-12-12 12:00:00'),
(5205, 65, 126, '1', '2000-12-12 12:00:00'),
(5206, 65, 127, '1', '2000-12-12 12:00:00'),
(5207, 65, 128, '1', '2000-12-12 12:00:00'),
(5208, 65, 129, '1', '2000-12-12 12:00:00'),
(5209, 65, 130, '1', '2000-12-12 12:00:00'),
(5210, 65, 131, '1', '2000-12-12 12:00:00'),
(5211, 65, 132, '1', '2000-12-12 12:00:00'),
(5212, 65, 133, '1', '2000-12-12 12:00:00'),
(5213, 65, 134, '1', '2000-12-12 12:00:00'),
(5214, 65, 135, '1', '2000-12-12 12:00:00'),
(5215, 65, 136, '1', '2000-12-12 12:00:00'),
(5216, 65, 137, '1', '2000-12-12 12:00:00'),
(5217, 65, 138, '1', '2000-12-12 12:00:00'),
(5218, 65, 139, '1', '2000-12-12 12:00:00'),
(5219, 65, 91, '1', '2000-12-12 12:00:00'),
(5220, 65, 140, '1', '2000-12-12 12:00:00'),
(5221, 65, 141, '1', '2000-12-12 12:00:00'),
(5222, 65, 142, '1', '2000-12-12 12:00:00'),
(5223, 65, 143, '1', '2000-12-12 12:00:00'),
(5224, 65, 144, '1', '2000-12-12 12:00:00'),
(5225, 65, 145, '1', '2000-12-12 12:00:00'),
(5226, 65, 146, '1', '2000-12-12 12:00:00'),
(5227, 65, 147, '1', '2000-12-12 12:00:00'),
(5228, 65, 148, '1', '2000-12-12 12:00:00'),
(5229, 65, 149, '1', '2000-12-12 12:00:00'),
(5230, 65, 46, '1', '2000-12-12 12:00:00'),
(5231, 65, 150, '1', '2000-12-12 12:00:00'),
(5232, 65, 151, '1', '2000-12-12 12:00:00'),
(5233, 65, 152, '1', '2000-12-12 12:00:00'),
(5234, 65, 105, '1', '2000-12-12 12:00:00'),
(5235, 65, 153, '1', '2000-12-12 12:00:00'),
(5236, 65, 154, '1', '2000-12-12 12:00:00'),
(5237, 65, 155, '1', '2000-12-12 12:00:00'),
(5238, 65, 156, '1', '2000-12-12 12:00:00'),
(5239, 65, 157, '1', '2000-12-12 12:00:00'),
(5289, 68, 158, '1', '2019-08-03 01:05:36'),
(5290, 68, 125, '2', '2019-08-03 01:20:03'),
(5291, 68, 108, '1', '2019-08-03 06:14:25'),
(5292, 68, 159, '3', '2019-08-03 06:14:32'),
(5293, 68, 160, '2', '2019-08-03 06:16:18'),
(5294, 68, 148, '2', '2019-08-03 06:06:16'),
(5295, 68, 142, '3', '2019-08-03 06:06:19'),
(5296, 68, 149, '3', '2019-08-03 06:06:20'),
(5297, 68, 32, '1', '2019-08-03 06:06:21'),
(5298, 68, 161, '1', '2019-08-03 01:01:04'),
(5299, 68, 162, '3', '2019-08-03 01:03:02'),
(5300, 68, 155, '1', '2019-08-03 01:03:05'),
(5301, 68, 153, '2', '2019-08-03 01:01:09'),
(5302, 69, 6, '1', '2000-12-12 12:00:00'),
(5303, 69, 7, '1', '2000-12-12 12:00:00'),
(5304, 69, 8, '1', '2000-12-12 12:00:00'),
(5305, 69, 9, '1', '2000-12-12 12:00:00'),
(5306, 69, 10, '1', '2000-12-12 12:00:00'),
(5307, 69, 11, '3', '2000-12-12 12:00:00'),
(5308, 69, 12, '2', '2000-12-12 12:00:00'),
(5309, 69, 13, '1', '2000-12-12 12:00:00'),
(5310, 69, 14, '0', '2000-12-12 12:00:00'),
(5311, 69, 15, '0', '2000-12-12 12:00:00'),
(5312, 69, 16, '0', '2000-12-12 12:00:00'),
(5313, 69, 17, '0', '2000-12-12 12:00:00'),
(5314, 69, 18, '0', '2000-12-12 12:00:00'),
(5315, 69, 19, '0', '2000-12-12 12:00:00'),
(5316, 69, 20, '0', '2000-12-12 12:00:00'),
(5317, 69, 21, '0', '2000-12-12 12:00:00'),
(5318, 69, 22, '0', '2000-12-12 12:00:00'),
(5319, 69, 35, '0', '2000-12-12 12:00:00'),
(5320, 69, 23, '0', '2000-12-12 12:00:00'),
(5321, 69, 24, '0', '2000-12-12 12:00:00'),
(5322, 69, 25, '0', '2000-12-12 12:00:00'),
(5323, 69, 26, '0', '2000-12-12 12:00:00'),
(5324, 69, 27, '0', '2000-12-12 12:00:00'),
(5325, 69, 28, '0', '2000-12-12 12:00:00'),
(5326, 69, 29, '0', '2000-12-12 12:00:00'),
(5327, 69, 30, '0', '2000-12-12 12:00:00'),
(5328, 69, 31, '0', '2000-12-12 12:00:00'),
(5329, 69, 32, '0', '2000-12-12 12:00:00'),
(5330, 69, 33, '0', '2000-12-12 12:00:00'),
(5331, 69, 34, '0', '2000-12-12 12:00:00'),
(5332, 69, 36, '0', '2000-12-12 12:00:00'),
(5333, 69, 37, '0', '2000-12-12 12:00:00'),
(5334, 69, 38, '0', '2000-12-12 12:00:00'),
(5335, 69, 39, '0', '2000-12-12 12:00:00'),
(5336, 69, 40, '0', '2000-12-12 12:00:00'),
(5337, 69, 41, '0', '2000-12-12 12:00:00'),
(5338, 69, 42, '0', '2000-12-12 12:00:00'),
(5339, 69, 43, '0', '2000-12-12 12:00:00'),
(5340, 69, 44, '0', '2000-12-12 12:00:00'),
(5341, 69, 45, '0', '2000-12-12 12:00:00'),
(5342, 69, 46, '0', '2000-12-12 12:00:00'),
(5343, 69, 47, '0', '2000-12-12 12:00:00'),
(5344, 69, 48, '0', '2000-12-12 12:00:00'),
(5345, 69, 49, '0', '2000-12-12 12:00:00'),
(5346, 69, 50, '0', '2000-12-12 12:00:00'),
(5347, 69, 51, '0', '2000-12-12 12:00:00'),
(5348, 69, 52, '0', '2000-12-12 12:00:00'),
(5349, 69, 53, '0', '2000-12-12 12:00:00'),
(5350, 69, 54, '0', '2000-12-12 12:00:00'),
(5351, 69, 55, '0', '2000-12-12 12:00:00'),
(5352, 69, 56, '0', '2000-12-12 12:00:00'),
(5353, 69, 57, '0', '2000-12-12 12:00:00'),
(5354, 69, 58, '0', '2000-12-12 12:00:00'),
(5355, 69, 59, '0', '2000-12-12 12:00:00'),
(5356, 69, 60, '0', '2000-12-12 12:00:00'),
(5357, 69, 5, '0', '2000-12-12 12:00:00'),
(5358, 69, 61, '0', '2000-12-12 12:00:00'),
(5359, 69, 62, '0', '2000-12-12 12:00:00'),
(5360, 69, 63, '0', '2000-12-12 12:00:00'),
(5361, 69, 64, '0', '2000-12-12 12:00:00'),
(5362, 69, 65, '0', '2000-12-12 12:00:00'),
(5363, 69, 66, '0', '2000-12-12 12:00:00'),
(5364, 69, 67, '0', '2000-12-12 12:00:00'),
(5365, 69, 68, '0', '2000-12-12 12:00:00'),
(5366, 69, 69, '0', '2000-12-12 12:00:00'),
(5367, 69, 70, '0', '2000-12-12 12:00:00'),
(5368, 69, 71, '0', '2000-12-12 12:00:00'),
(5369, 69, 72, '0', '2000-12-12 12:00:00'),
(5370, 69, 73, '0', '2000-12-12 12:00:00'),
(5371, 69, 74, '0', '2000-12-12 12:00:00'),
(5372, 69, 75, '0', '2000-12-12 12:00:00'),
(5373, 69, 76, '0', '2000-12-12 12:00:00'),
(5374, 69, 77, '0', '2000-12-12 12:00:00'),
(5375, 69, 78, '0', '2000-12-12 12:00:00'),
(5376, 69, 79, '0', '2000-12-12 12:00:00'),
(5377, 69, 80, '0', '2000-12-12 12:00:00'),
(5378, 69, 81, '0', '2000-12-12 12:00:00'),
(5379, 69, 82, '0', '2000-12-12 12:00:00'),
(5380, 69, 2, '0', '2000-12-12 12:00:00'),
(5381, 69, 83, '0', '2000-12-12 12:00:00'),
(5382, 69, 84, '0', '2000-12-12 12:00:00'),
(5383, 69, 85, '0', '2000-12-12 12:00:00'),
(5384, 69, 86, '0', '2000-12-12 12:00:00'),
(5385, 69, 87, '0', '2000-12-12 12:00:00'),
(5386, 69, 88, '0', '2000-12-12 12:00:00'),
(5387, 69, 89, '0', '2000-12-12 12:00:00'),
(5388, 69, 90, '0', '2000-12-12 12:00:00'),
(5389, 69, 91, '0', '2000-12-12 12:00:00'),
(5390, 69, 92, '0', '2000-12-12 12:00:00'),
(5391, 69, 93, '0', '2000-12-12 12:00:00'),
(5392, 69, 94, '0', '2000-12-12 12:00:00'),
(5393, 69, 95, '0', '2000-12-12 12:00:00'),
(5394, 69, 96, '0', '2000-12-12 12:00:00'),
(5395, 69, 97, '0', '2000-12-12 12:00:00'),
(5396, 69, 98, '0', '2000-12-12 12:00:00'),
(5397, 69, 99, '0', '2000-12-12 12:00:00'),
(5398, 69, 100, '0', '2000-12-12 12:00:00'),
(5399, 69, 101, '0', '2000-12-12 12:00:00'),
(5400, 69, 102, '0', '2000-12-12 12:00:00'),
(5401, 69, 103, '0', '2000-12-12 12:00:00'),
(5402, 69, 104, '0', '2000-12-12 12:00:00'),
(5403, 69, 105, '0', '2000-12-12 12:00:00'),
(5404, 69, 106, '0', '2000-12-12 12:00:00'),
(5405, 69, 107, '0', '2000-12-12 12:00:00'),
(5406, 69, 108, '0', '2000-12-12 12:00:00'),
(5407, 69, 109, '0', '2000-12-12 12:00:00'),
(5408, 69, 110, '0', '2000-12-12 12:00:00'),
(5409, 69, 111, '0', '2000-12-12 12:00:00'),
(5410, 69, 113, '0', '2000-12-12 12:00:00'),
(5411, 69, 112, '0', '2000-12-12 12:00:00'),
(5412, 69, 114, '0', '2000-12-12 12:00:00'),
(5413, 69, 115, '0', '2000-12-12 12:00:00'),
(5414, 69, 116, '0', '2000-12-12 12:00:00'),
(5415, 69, 117, '0', '2000-12-12 12:00:00'),
(5416, 69, 118, '0', '2000-12-12 12:00:00'),
(5417, 69, 119, '0', '2000-12-12 12:00:00'),
(5418, 69, 120, '0', '2000-12-12 12:00:00'),
(5419, 69, 121, '0', '2000-12-12 12:00:00'),
(5420, 69, 122, '0', '2000-12-12 12:00:00'),
(5421, 69, 123, '0', '2000-12-12 12:00:00'),
(5422, 69, 124, '0', '2000-12-12 12:00:00'),
(5423, 69, 125, '0', '2000-12-12 12:00:00'),
(5424, 69, 126, '0', '2000-12-12 12:00:00'),
(5425, 69, 127, '0', '2000-12-12 12:00:00'),
(5426, 69, 128, '0', '2000-12-12 12:00:00'),
(5427, 69, 129, '0', '2000-12-12 12:00:00'),
(5428, 69, 130, '0', '2000-12-12 12:00:00'),
(5429, 69, 131, '0', '2000-12-12 12:00:00'),
(5430, 69, 132, '0', '2000-12-12 12:00:00'),
(5431, 69, 133, '0', '2000-12-12 12:00:00'),
(5432, 69, 134, '0', '2000-12-12 12:00:00'),
(5433, 69, 135, '0', '2000-12-12 12:00:00'),
(5434, 69, 136, '0', '2000-12-12 12:00:00'),
(5435, 69, 137, '0', '2000-12-12 12:00:00'),
(5436, 69, 138, '0', '2000-12-12 12:00:00'),
(5437, 69, 139, '0', '2000-12-12 12:00:00'),
(5438, 69, 140, '0', '2000-12-12 12:00:00'),
(5439, 69, 141, '0', '2000-12-12 12:00:00'),
(5440, 69, 142, '0', '2000-12-12 12:00:00'),
(5441, 69, 143, '0', '2000-12-12 12:00:00'),
(5442, 69, 144, '0', '2000-12-12 12:00:00'),
(5443, 69, 145, '0', '2000-12-12 12:00:00'),
(5444, 69, 146, '0', '2000-12-12 12:00:00'),
(5445, 69, 147, '0', '2000-12-12 12:00:00'),
(5446, 69, 148, '0', '2000-12-12 12:00:00'),
(5447, 69, 149, '0', '2000-12-12 12:00:00'),
(5448, 69, 150, '0', '2000-12-12 12:00:00'),
(5449, 69, 151, '0', '2000-12-12 12:00:00'),
(5450, 69, 152, '0', '2000-12-12 12:00:00'),
(5451, 69, 153, '0', '2000-12-12 12:00:00'),
(5452, 69, 154, '0', '2000-12-12 12:00:00'),
(5453, 69, 155, '0', '2000-12-12 12:00:00'),
(5454, 69, 156, '0', '2000-12-12 12:00:00'),
(5455, 69, 157, '0', '2000-12-12 12:00:00'),
(5456, 69, 158, '0', '2000-12-12 12:00:00'),
(5457, 69, 159, '0', '2000-12-12 12:00:00'),
(5458, 69, 160, '0', '2000-12-12 12:00:00'),
(5459, 69, 161, '0', '2000-12-12 12:00:00'),
(5460, 69, 162, '0', '2000-12-12 12:00:00'),
(5461, 69, 165, '0', '2000-12-12 12:00:00'),
(5462, 69, 166, '0', '2000-12-12 12:00:00'),
(5463, 69, 167, '0', '2000-12-12 12:00:00'),
(5464, 69, 168, '0', '2000-12-12 12:00:00'),
(5465, 69, 169, '0', '2000-12-12 12:00:00'),
(5466, 69, 170, '0', '2000-12-12 12:00:00'),
(5467, 69, 171, '0', '2000-12-12 12:00:00'),
(5468, 69, 172, '0', '2000-12-12 12:00:00'),
(5469, 69, 173, '0', '2000-12-12 12:00:00'),
(5470, 69, 174, '0', '2000-12-12 12:00:00'),
(5471, 69, 175, '0', '2000-12-12 12:00:00'),
(5472, 69, 176, '0', '2000-12-12 12:00:00'),
(5473, 69, 177, '0', '2000-12-12 12:00:00'),
(5474, 69, 178, '0', '2000-12-12 12:00:00'),
(5475, 69, 179, '0', '2000-12-12 12:00:00'),
(5476, 69, 180, '0', '2000-12-12 12:00:00'),
(5477, 69, 181, '0', '2000-12-12 12:00:00'),
(5478, 69, 182, '0', '2000-12-12 12:00:00'),
(5479, 69, 183, '0', '2000-12-12 12:00:00'),
(5480, 69, 184, '0', '2000-12-12 12:00:00'),
(5481, 69, 185, '0', '2000-12-12 12:00:00'),
(5482, 69, 186, '0', '2000-12-12 12:00:00'),
(5483, 69, 187, '0', '2000-12-12 12:00:00'),
(5484, 69, 188, '0', '2000-12-12 12:00:00'),
(5485, 69, 189, '0', '2000-12-12 12:00:00'),
(5486, 69, 190, '0', '2000-12-12 12:00:00'),
(5487, 69, 191, '0', '2000-12-12 12:00:00'),
(5488, 69, 192, '0', '2000-12-12 12:00:00'),
(5489, 69, 193, '0', '2000-12-12 12:00:00'),
(5490, 69, 194, '0', '2000-12-12 12:00:00'),
(5504, 71, 6, '1', '2019-08-04 13:00:52'),
(5505, 71, 7, '3', '2000-12-12 12:00:00'),
(5506, 71, 8, '3', '2000-12-12 12:00:00'),
(5507, 71, 9, '1', '2019-08-03 02:06:05'),
(5508, 71, 10, '1', '2019-08-03 02:06:21'),
(5509, 71, 11, '1', '2019-08-03 02:39:07'),
(5510, 71, 12, '2', '2019-08-03 02:38:20'),
(5511, 71, 13, '2', '2019-08-03 02:38:45'),
(5512, 71, 14, '1', '2019-08-04 13:03:25'),
(5513, 71, 15, '2', '2019-08-03 02:40:16'),
(5514, 71, 16, '3', '2019-08-03 02:39:57'),
(5515, 71, 17, '1', '2019-08-03 02:41:41'),
(5516, 71, 18, '0', '2000-12-12 12:00:00'),
(5517, 71, 19, '0', '2000-12-12 12:00:00'),
(5518, 71, 20, '0', '2000-12-12 12:00:00'),
(5519, 71, 21, '0', '2000-12-12 12:00:00'),
(5520, 71, 22, '0', '2000-12-12 12:00:00'),
(5521, 71, 35, '0', '2000-12-12 12:00:00'),
(5522, 71, 23, '0', '2000-12-12 12:00:00'),
(5523, 71, 24, '0', '2000-12-12 12:00:00'),
(5524, 71, 25, '0', '2000-12-12 12:00:00'),
(5525, 71, 26, '0', '2000-12-12 12:00:00'),
(5526, 71, 27, '0', '2000-12-12 12:00:00'),
(5527, 71, 28, '0', '2000-12-12 12:00:00'),
(5528, 71, 29, '0', '2000-12-12 12:00:00'),
(5529, 71, 30, '0', '2000-12-12 12:00:00'),
(5530, 71, 31, '0', '2000-12-12 12:00:00'),
(5531, 71, 32, '0', '2000-12-12 12:00:00'),
(5532, 71, 33, '0', '2000-12-12 12:00:00'),
(5533, 71, 34, '0', '2000-12-12 12:00:00'),
(5534, 71, 36, '0', '2000-12-12 12:00:00'),
(5535, 71, 37, '0', '2000-12-12 12:00:00'),
(5536, 71, 38, '0', '2000-12-12 12:00:00'),
(5537, 71, 39, '0', '2000-12-12 12:00:00'),
(5538, 71, 40, '0', '2000-12-12 12:00:00'),
(5539, 71, 41, '0', '2000-12-12 12:00:00'),
(5540, 71, 42, '0', '2000-12-12 12:00:00'),
(5541, 71, 43, '0', '2000-12-12 12:00:00'),
(5542, 71, 44, '0', '2000-12-12 12:00:00'),
(5543, 71, 45, '0', '2000-12-12 12:00:00'),
(5544, 71, 46, '0', '2000-12-12 12:00:00'),
(5545, 71, 47, '0', '2000-12-12 12:00:00'),
(5546, 71, 48, '0', '2000-12-12 12:00:00'),
(5547, 71, 49, '0', '2000-12-12 12:00:00'),
(5548, 71, 50, '0', '2000-12-12 12:00:00'),
(5549, 71, 51, '0', '2000-12-12 12:00:00'),
(5550, 71, 52, '0', '2000-12-12 12:00:00'),
(5551, 71, 53, '0', '2000-12-12 12:00:00'),
(5552, 71, 54, '0', '2000-12-12 12:00:00'),
(5553, 71, 55, '0', '2000-12-12 12:00:00'),
(5554, 71, 56, '0', '2000-12-12 12:00:00'),
(5555, 71, 57, '0', '2000-12-12 12:00:00'),
(5556, 71, 58, '0', '2000-12-12 12:00:00'),
(5557, 71, 59, '0', '2000-12-12 12:00:00'),
(5558, 71, 60, '0', '2000-12-12 12:00:00'),
(5559, 71, 5, '0', '2000-12-12 12:00:00'),
(5560, 71, 61, '0', '2000-12-12 12:00:00'),
(5561, 71, 62, '0', '2000-12-12 12:00:00'),
(5562, 71, 63, '0', '2000-12-12 12:00:00'),
(5563, 71, 64, '0', '2000-12-12 12:00:00'),
(5564, 71, 65, '0', '2000-12-12 12:00:00'),
(5565, 71, 66, '0', '2000-12-12 12:00:00'),
(5566, 71, 67, '0', '2000-12-12 12:00:00'),
(5567, 71, 68, '0', '2000-12-12 12:00:00'),
(5568, 71, 69, '0', '2000-12-12 12:00:00'),
(5569, 71, 70, '0', '2000-12-12 12:00:00'),
(5570, 71, 71, '0', '2000-12-12 12:00:00'),
(5571, 71, 72, '0', '2000-12-12 12:00:00'),
(5572, 71, 73, '0', '2000-12-12 12:00:00'),
(5573, 71, 74, '0', '2000-12-12 12:00:00'),
(5574, 71, 75, '0', '2000-12-12 12:00:00'),
(5575, 71, 76, '2', '2019-08-03 02:44:30'),
(5576, 71, 77, '0', '2000-12-12 12:00:00'),
(5577, 71, 78, '0', '2000-12-12 12:00:00'),
(5578, 71, 79, '0', '2000-12-12 12:00:00'),
(5579, 71, 80, '0', '2000-12-12 12:00:00'),
(5580, 71, 81, '0', '2000-12-12 12:00:00'),
(5581, 71, 82, '0', '2000-12-12 12:00:00'),
(5582, 71, 2, '0', '2000-12-12 12:00:00'),
(5583, 71, 83, '0', '2000-12-12 12:00:00'),
(5584, 71, 84, '0', '2000-12-12 12:00:00'),
(5585, 71, 85, '0', '2000-12-12 12:00:00'),
(5586, 71, 86, '0', '2000-12-12 12:00:00'),
(5587, 71, 87, '0', '2000-12-12 12:00:00'),
(5588, 71, 88, '0', '2000-12-12 12:00:00'),
(5589, 71, 89, '0', '2000-12-12 12:00:00'),
(5590, 71, 90, '0', '2000-12-12 12:00:00'),
(5591, 71, 91, '0', '2000-12-12 12:00:00'),
(5592, 71, 92, '0', '2000-12-12 12:00:00'),
(5593, 71, 93, '0', '2000-12-12 12:00:00'),
(5594, 71, 94, '0', '2000-12-12 12:00:00'),
(5595, 71, 95, '0', '2000-12-12 12:00:00'),
(5596, 71, 96, '0', '2000-12-12 12:00:00'),
(5597, 71, 97, '0', '2000-12-12 12:00:00'),
(5598, 71, 98, '0', '2000-12-12 12:00:00'),
(5599, 71, 99, '0', '2000-12-12 12:00:00'),
(5600, 71, 100, '0', '2000-12-12 12:00:00'),
(5601, 71, 101, '0', '2000-12-12 12:00:00'),
(5602, 71, 102, '0', '2000-12-12 12:00:00'),
(5603, 71, 103, '0', '2000-12-12 12:00:00'),
(5604, 71, 104, '0', '2000-12-12 12:00:00'),
(5605, 71, 105, '0', '2000-12-12 12:00:00'),
(5606, 71, 106, '0', '2000-12-12 12:00:00'),
(5607, 71, 107, '0', '2000-12-12 12:00:00'),
(5608, 71, 108, '0', '2000-12-12 12:00:00'),
(5609, 71, 109, '0', '2000-12-12 12:00:00'),
(5610, 71, 110, '0', '2000-12-12 12:00:00'),
(5611, 71, 111, '0', '2000-12-12 12:00:00'),
(5612, 71, 113, '0', '2000-12-12 12:00:00'),
(5613, 71, 112, '0', '2000-12-12 12:00:00'),
(5614, 71, 114, '0', '2000-12-12 12:00:00'),
(5615, 71, 115, '0', '2000-12-12 12:00:00'),
(5616, 71, 116, '0', '2000-12-12 12:00:00'),
(5617, 71, 117, '0', '2000-12-12 12:00:00'),
(5618, 71, 118, '0', '2000-12-12 12:00:00'),
(5619, 71, 119, '0', '2000-12-12 12:00:00'),
(5620, 71, 120, '0', '2000-12-12 12:00:00'),
(5621, 71, 121, '0', '2000-12-12 12:00:00'),
(5622, 71, 122, '0', '2000-12-12 12:00:00'),
(5623, 71, 123, '0', '2000-12-12 12:00:00'),
(5624, 71, 124, '0', '2000-12-12 12:00:00'),
(5625, 71, 125, '0', '2000-12-12 12:00:00'),
(5626, 71, 126, '0', '2000-12-12 12:00:00'),
(5627, 71, 127, '0', '2000-12-12 12:00:00'),
(5628, 71, 128, '0', '2000-12-12 12:00:00'),
(5629, 71, 129, '0', '2000-12-12 12:00:00'),
(5630, 71, 130, '0', '2000-12-12 12:00:00'),
(5631, 71, 131, '0', '2000-12-12 12:00:00'),
(5632, 71, 132, '0', '2000-12-12 12:00:00'),
(5633, 71, 133, '0', '2000-12-12 12:00:00'),
(5634, 71, 134, '0', '2000-12-12 12:00:00'),
(5635, 71, 135, '0', '2000-12-12 12:00:00'),
(5636, 71, 136, '0', '2000-12-12 12:00:00'),
(5637, 71, 137, '0', '2000-12-12 12:00:00'),
(5638, 71, 138, '0', '2000-12-12 12:00:00'),
(5639, 71, 139, '0', '2000-12-12 12:00:00'),
(5640, 71, 140, '0', '2000-12-12 12:00:00'),
(5641, 71, 141, '0', '2000-12-12 12:00:00'),
(5642, 71, 142, '0', '2000-12-12 12:00:00'),
(5643, 71, 143, '0', '2000-12-12 12:00:00'),
(5644, 71, 144, '0', '2000-12-12 12:00:00'),
(5645, 71, 145, '0', '2000-12-12 12:00:00'),
(5646, 71, 146, '0', '2000-12-12 12:00:00'),
(5647, 71, 147, '0', '2000-12-12 12:00:00'),
(5648, 71, 148, '0', '2000-12-12 12:00:00'),
(5649, 71, 149, '0', '2000-12-12 12:00:00'),
(5650, 71, 150, '0', '2000-12-12 12:00:00'),
(5651, 71, 151, '0', '2000-12-12 12:00:00'),
(5652, 71, 152, '0', '2000-12-12 12:00:00'),
(5653, 71, 153, '0', '2000-12-12 12:00:00'),
(5654, 71, 154, '0', '2000-12-12 12:00:00'),
(5655, 71, 155, '0', '2000-12-12 12:00:00'),
(5656, 71, 156, '0', '2000-12-12 12:00:00'),
(5657, 71, 157, '0', '2000-12-12 12:00:00'),
(5658, 71, 158, '0', '2000-12-12 12:00:00'),
(5659, 71, 159, '0', '2000-12-12 12:00:00'),
(5660, 71, 160, '0', '2000-12-12 12:00:00'),
(5661, 71, 161, '0', '2000-12-12 12:00:00'),
(5662, 71, 162, '0', '2000-12-12 12:00:00'),
(5663, 71, 165, '0', '2000-12-12 12:00:00'),
(5664, 71, 166, '0', '2000-12-12 12:00:00'),
(5665, 71, 167, '0', '2000-12-12 12:00:00'),
(5666, 71, 168, '0', '2000-12-12 12:00:00'),
(5667, 71, 169, '0', '2000-12-12 12:00:00'),
(5668, 71, 170, '0', '2000-12-12 12:00:00'),
(5669, 71, 171, '0', '2000-12-12 12:00:00'),
(5670, 71, 172, '0', '2000-12-12 12:00:00'),
(5671, 71, 173, '0', '2000-12-12 12:00:00'),
(5672, 71, 174, '0', '2000-12-12 12:00:00'),
(5673, 71, 175, '0', '2000-12-12 12:00:00'),
(5674, 71, 176, '0', '2000-12-12 12:00:00'),
(5675, 71, 177, '0', '2000-12-12 12:00:00'),
(5676, 71, 178, '0', '2000-12-12 12:00:00'),
(5677, 71, 179, '0', '2000-12-12 12:00:00'),
(5678, 71, 180, '0', '2000-12-12 12:00:00'),
(5679, 71, 181, '0', '2000-12-12 12:00:00'),
(5680, 71, 182, '0', '2000-12-12 12:00:00'),
(5681, 71, 183, '0', '2000-12-12 12:00:00'),
(5682, 71, 184, '0', '2000-12-12 12:00:00'),
(5683, 71, 185, '0', '2000-12-12 12:00:00'),
(5684, 71, 186, '0', '2000-12-12 12:00:00'),
(5685, 71, 187, '0', '2000-12-12 12:00:00'),
(5686, 71, 188, '0', '2000-12-12 12:00:00'),
(5687, 71, 189, '0', '2000-12-12 12:00:00'),
(5688, 71, 190, '0', '2000-12-12 12:00:00'),
(5689, 71, 191, '0', '2000-12-12 12:00:00'),
(5690, 71, 192, '0', '2000-12-12 12:00:00'),
(5691, 71, 193, '0', '2000-12-12 12:00:00'),
(5692, 71, 194, '0', '2000-12-12 12:00:00');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `limpieza`
--

CREATE TABLE `limpieza` (
  `id_limpieza` int(11) NOT NULL,
  `decripcion` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `tipo` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `fecha_registro` date DEFAULT NULL,
  `fecha_limpieza` date DEFAULT NULL,
  `fecha_revision` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `lista`
--

CREATE TABLE `lista` (
  `id_lista` int(11) NOT NULL,
  `id_comite` int(11) DEFAULT NULL,
  `nombre_lista` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `fecha_creacion` datetime DEFAULT NULL,
  `estado` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `foto` varchar(150) COLLATE hp8_bin DEFAULT NULL,
  `fecha_inicio` date DEFAULT NULL,
  `fecha_termino` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `multa`
--

CREATE TABLE `multa` (
  `id_multa` int(11) NOT NULL,
  `concepto` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `fecha` datetime DEFAULT NULL,
  `estado` varchar(10) COLLATE hp8_bin DEFAULT NULL,
  `tipo` varchar(15) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `multa_asistencia`
--

CREATE TABLE `multa_asistencia` (
  `id_multa_asistencia` int(11) NOT NULL,
  `id_multa` int(11) NOT NULL,
  `id_hoja_asistencia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `multa_limpia`
--

CREATE TABLE `multa_limpia` (
  `id_multa_limpia` int(11) NOT NULL,
  `id_multa` int(11) NOT NULL,
  `id_det_limpia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `multa_orden`
--

CREATE TABLE `multa_orden` (
  `id_multa_orden` int(11) NOT NULL,
  `id_orden` int(11) NOT NULL,
  `id_multa` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `noticia`
--

CREATE TABLE `noticia` (
  `id_noticia` int(11) NOT NULL,
  `titular` varchar(45) COLLATE hp8_bin DEFAULT NULL,
  `descripcion` varchar(400) COLLATE hp8_bin DEFAULT NULL,
  `fecha` datetime DEFAULT NULL,
  `foto` varchar(150) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `noticia`
--

INSERT INTO `noticia` (`id_noticia`, `titular`, `descripcion`, `fecha`, `foto`) VALUES
(1, 'Titulación Gratuita', 'La ONG Sedepas Norte brindará una campaña de titulación gratuita para toso los usuarios del comité de regantes Nuevo Horizonte', '2018-10-24 00:00:00', 'photos/img006.jpg'),
(2, 'Tía Nilda', 'La sra Nilda Barrios donará un puente en el Ramal 3', '2018-10-28 00:00:00', 'photos/1.PNG'),
(3, 'aaaa', 'ccc', '2019-06-15 00:00:00', 'photos/20180511_211637.jpg');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `obra`
--

CREATE TABLE `obra` (
  `id_obra` int(11) NOT NULL,
  `id_canal` int(11) DEFAULT NULL,
  `decripcion` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `monto` double DEFAULT NULL,
  `foto` varchar(150) COLLATE hp8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `orden_riego`
--

CREATE TABLE `orden_riego` (
  `id_orden_riego` int(11) NOT NULL,
  `id_reparto` int(11) DEFAULT NULL,
  `id_parcela` int(11) DEFAULT NULL,
  `fecha_establecida` date DEFAULT NULL,
  `fecha_inicio` datetime DEFAULT NULL,
  `duracion` double DEFAULT NULL,
  `unidad` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `cantidad_has` double DEFAULT NULL,
  `importe` double DEFAULT NULL,
  `estado` varchar(20) COLLATE hp8_bin DEFAULT NULL,
  `id_comprobante` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `orden_riego`
--

INSERT INTO `orden_riego` (`id_orden_riego`, `id_reparto`, `id_parcela`, `fecha_establecida`, `fecha_inicio`, `duracion`, `unidad`, `cantidad_has`, `importe`, `estado`, `id_comprobante`) VALUES
(1, 12, 1, '2019-08-17', '2019-08-17 02:02:00', 4.5, 'h', 4.5, 11.25, 'Aprobada', NULL),
(2, 12, 3, '2019-08-17', '2019-08-17 12:17:00', 10, 'h', 10, 25, 'Aprobada', NULL),
(3, 10, 7, '2019-08-05', NULL, 3, 'h', 3, 7.5, 'Solicitada', NULL),
(4, 14, 6, '2019-08-05', NULL, 2, 'h', 2, 5, 'Solicitada', NULL),
(5, 13, 5, '2019-08-05', NULL, 2.5, 'h', 2.5, 6.25, 'Aprobada', NULL),
(6, 13, 4, '2019-08-05', NULL, 3.5, 'h', 3.5, 8.75, 'Aprobada', NULL),
(7, 13, 9, '2019-08-05', NULL, 1.5, 'h', 1.5, 3.75, 'Aprobada', NULL),
(8, 13, 60, '2019-08-05', NULL, 0.5, 'h', 0.5, 1.25, 'Aprobada', NULL),
(9, 13, 119, '2019-08-05', NULL, 1, 'h', 1, 2.5, 'Aprobada', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `parcela`
--

CREATE TABLE `parcela` (
  `id_parcela` int(11) NOT NULL,
  `nombre` varchar(60) COLLATE hp8_bin DEFAULT NULL,
  `ubicacion` varchar(150) COLLATE hp8_bin DEFAULT NULL,
  `num_toma` int(11) DEFAULT NULL,
  `id_canal` int(11) DEFAULT NULL,
  `id_auth_user` int(11) DEFAULT NULL,
  `total_has` double DEFAULT NULL,
  `has_sembradas` double DEFAULT NULL,
  `descripcion` varchar(100) COLLATE hp8_bin DEFAULT NULL,
  `estado` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `codigo_predio` varchar(25) COLLATE hp8_bin NOT NULL,
  `volumen_agua` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `parcela`
--

INSERT INTO `parcela` (`id_parcela`, `nombre`, `ubicacion`, `num_toma`, `id_canal`, `id_auth_user`, `total_has`, `has_sembradas`, `descripcion`, `estado`, `codigo_predio`, `volumen_agua`) VALUES
(1, 'El Algarrobo', 'ramal 1', 1, 1, 6, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(2, 'Ramoncito A', 'ramal 1', 2, 1, 7, 0.54, 0.54, 'sin descripciµn', '1', 'null', 2484),
(3, 'Ramoncito B', 'ramal 1', 3, 1, 7, 0.44, 0.44, 'sin descripciµn', '1', 'null', 2024),
(4, 'Los Julios', 'ramal 1', 4, 1, 8, 3.66, 1, 'sin descripciµn', '1', 'null', 4600),
(5, 'El Guabo', 'ramal 1', 5, 1, 9, 1.75, 1, 'sin descripciµn', '1', 'null', 4600),
(6, 'El Puente', 'ramal 1', 6, 1, 10, 1.24, 1, 'sin descripciµn', '1', 'null', 4600),
(7, 'Los Girasoles', 'ramal 1', 7, 1, 11, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(8, 'Los Jardines', 'ramal 1', 8, 1, 12, 2.11, 1, 'sin descripciµn', '1', 'null', 4600),
(9, 'El Pozo', 'ramal 1', 9, 1, 13, 0.92, 0.92, 'sin descripciµn', '1', 'null', 4232),
(10, 'El Pozo', 'ramal 1', 10, 1, 14, 0.5, 0.5, 'sin descripciµn', '1', 'null', 1300),
(11, 'Naranja', 'ramal 1', 11, 1, 15, 1.32, 1.32, 'sin descripciµn', '1', 'null', 6072),
(12, 'La 63', 'ramal 1', 12, 1, 16, 0.99, 0.99, 'sin descripciµn', '1', 'null', 4554),
(13, 'Chilo', 'ramal 1', 13, 1, 17, 0.87, 0.87, 'sin descripciµn', '1', 'null', 4094),
(14, 'La 61', 'ramal 1', 14, 1, 18, 0.68, 0.68, 'sin descripciµn', '1', 'null', 3128),
(15, 'La Estrella', 'ramal 1', 15, 1, 19, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(16, 'El Eucalipto', 'ramal 1', 16, 1, 20, 2.63, 1, 'sin descripciµn', '1', 'null', 4600),
(17, 'El Limµn', 'ramal 1', 17, 1, 21, 2.44, 2, 'sin descripciµn', '1', 'null', 9200),
(18, 'El Pozo', 'ramal 1', 18, 1, 22, 0.81, 0.81, 'sin descripciµn', '1', 'null', 3726),
(19, 'Ana Myle 3', 'ramal 1', 19, 1, 35, 0.99, 0.99, 'sin descripciµn', '1', 'null', 4554),
(20, 'Alexandra', 'ramal 1', 20, 1, 23, 0.98, 0.98, 'sin descripciµn', '1', 'null', 4508),
(21, 'La Palmera', 'ramal 1', 21, 1, 24, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(22, 'La Caþa ', 'ramal 1', 22, 1, 25, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(23, 'El Huerto', 'ramal 1', 23, 1, 26, 1.03, 1.03, 'sin descripciµn', '1', 'null', 4738),
(24, 'Soledad', 'ramal 1', 24, 1, 27, 1.05, 1.05, 'sin descripciµn', '1', 'null', 4830),
(25, 'La Huerta', 'ramal 1', 25, 1, 28, 0.99, 0.99, 'sin descripciµn', '1', 'null', 4554),
(26, 'El Algarrobo', 'ramal 1', 26, 1, 29, 0.86, 0.86, 'sin descripciµn', '1', 'null', 3956),
(27, 'El Pino', 'ramal 1', 27, 1, 30, 1.01, 1.01, 'sin descripciµn', '1', 'null', 4646),
(28, 'MatÚas', 'ramal 1', 28, 1, 31, 1.94, 1.94, 'sin descripciµn', '1', 'null', 8924),
(29, 'El Limµn', 'ramal 1', 29, 1, 32, 0.96, 0.96, 'sin descripciµn', '1', 'null', 4416),
(30, 'La MaracuyÃ', 'ramal 1', 30, 1, 33, 0.94, 0.94, 'sin descripciµn', '1', 'null', 4324),
(31, 'La Tranca', 'ramal 1', 31, 1, 34, 1.02, 1.02, 'sin descripciµn', '1', 'null', 4692),
(32, 'Ana Myle 2', 'ramal 1', 32, 1, 35, 0.89, 0.89, 'sin descripciµn', '1', 'null', 4094),
(33, 'Noni', 'ramal 1', 33, 1, 36, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(34, 'Los Chilenos', 'ramal 1', 34, 1, 37, 2, 2, 'sin descripciµn', '1', 'null', 9200),
(35, 'Los Huabitos', 'ramal 1', 35, 1, 38, 2.58, 1.5, 'sin descripciµn', '1', 'null', 6900),
(36, 'La MaracuyÃ', 'ramal 1', 36, 1, 39, 0.97, 0.97, 'sin descripciµn', '1', 'null', 4462),
(37, 'El Guabo', 'ramal 1', 37, 1, 40, 1.15, 1.15, 'sin descripciµn', '1', 'null', 5290),
(38, 'La TÚa FelÃ', 'ramal 1', 38, 1, 41, 1.17, 1.17, 'sin descripciµn', '1', 'null', 5382),
(39, 'El Letrero', 'ramal 1', 39, 1, 42, 0.6, 0.6, 'sin descripciµn', '1', 'null', 2760),
(40, 'Las Vegas', 'ramal 1', 40, 1, 43, 1.27, 1.27, 'sin descripciµn', '1', 'null', 5842),
(41, 'Los PlÃtanos', 'ramal 1', 41, 1, 44, 0.94, 0.94, 'sin descripciµn', '1', 'null', 4324),
(42, 'Las Vegas', 'ramal 2', 1, 2, 43, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(43, 'El Milagro', 'ramal 2', 2, 2, 45, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(44, 'La 28', 'ramal 2', 3, 2, 46, 1.25, 1.25, 'sin descripciµn', '1', 'null', 5750),
(45, 'Parcela N¯ 25', 'ramal 2', 4, 2, 47, 2.04, 2.04, 'sin descripciµn', '1', 'null', 9384),
(46, 'La Chirimoya', 'ramal 2', 5, 2, 48, 1.24, 1.24, 'sin descripciµn', '1', 'null', 5704),
(47, 'El Limµn', 'ramal 2', 6, 2, 18, 1.95, 1.95, 'sin descripciµn', '1', 'null', 8970),
(48, 'El Molino', 'ramal 2', 7, 2, 49, 3.19, 3.19, 'sin descripciµn', '1', 'null', 14674),
(49, 'La Curva', 'ramal 2', 8, 2, 50, 0.93, 0.93, 'sin descripciµn', '1', 'null', 4278),
(50, 'El Tallo', 'ramal 2', 9, 2, 51, 0.95, 0.95, 'sin descripciµn', '1', 'null', 4370),
(51, 'El Huabo', 'ramal 2', 10, 2, 52, 1.05, 1.05, 'sin descripciµn', '1', 'null', 4830),
(52, 'La Hierba luisa', 'ramal 2', 11, 2, 53, 1.03, 1.03, 'sin descripciµn', '1', 'null', 4738),
(53, 'El Girasol', 'ramal 2', 12, 2, 54, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(54, 'El Pozo', 'ramal 2', 13, 2, 55, 0.98, 0.98, 'sin descripciµn', '1', 'null', 4508),
(55, 'Santa Maria', 'ramal 2', 14, 2, 56, 1.27, 1.27, 'sin descripciµn', '1', 'null', 5842),
(56, 'El Ventarrµn', 'ramal 2', 15, 2, 57, 0.91, 0.91, 'sin descripciµn', '1', 'null', 4186),
(57, 'La Guaba', 'ramal 2', 16, 2, 58, 4.84, 3, 'sin descripciµn', '1', 'null', 13800),
(58, 'La Perla ', 'ramal 2', 17, 2, 11, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(59, 'Jara', 'ramal 2', 18, 2, 59, 2.73, 2.5, 'sin descripciµn', '1', 'null', 11500),
(60, 'La Palta', 'ramal 2', 19, 2, 13, 2.82, 2.82, 'sin descripciµn', '1', 'null', 12972),
(61, 'El Tamarindo B', 'ramal 2', 20, 2, 60, 1.02, 1.02, 'sin descripciµn', '1', 'null', 4692),
(62, 'El Tamarindo A', 'ramal 2', 21, 2, 60, 0.9, 30, 'sin descripciµn', '1', 'null', 4140),
(63, 'El Algarrobo', 'ramal 2', 22, 2, 5, 1.23, 1.23, 'sin descripciµn', '1', 'null', 5658),
(64, 'El Mango', 'ramal 2', 23, 2, 61, 2.27, 2.27, 'sin descripciµn', '1', 'null', 10442),
(65, 'El Manantial', 'ramal 2', 24, 2, 62, 4.88, 4, 'sin descripciµn', '1', 'null', 18400),
(66, 'El Elefante', 'ramal 2', 25, 2, 29, 0, 0, 'sin descripciµn', '1', 'null', 23690),
(67, 'Los Mangos', 'ramal 2', 26, 2, 63, 2.06, 2.06, 'sin descripciµn', '1', 'null', 9476),
(68, 'El Algarrobo', 'ramal 2', 27, 2, 64, 3.06, 3.06, 'sin descripciµn', '1', 'null', 14076),
(69, 'El Girasol II', 'ramal 2', 28, 2, 54, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(70, 'La 16', 'ramal 2', 29, 2, 16, 5.07, 5.07, 'sin descripciµn', '1', 'null', 23322),
(71, 'La Ponderosa', 'ramal 2', 30, 2, 65, 1.08, 1.08, 'sin descripciµn', '1', 'null', 4968),
(72, 'Las Gaviotas', 'ramal 2', 31, 2, 27, 3.84, 1.5, 'sin descripciµn', '1', 'null', 6900),
(73, 'Las Tunas', 'ramal 2', 32, 2, 66, 1.6, 1.6, 'sin descripciµn', '1', 'null', 7360),
(74, 'Beal', 'ramal 2', 33, 2, 67, 8.2, 4, 'sin descripciµn', '1', 'null', 18400),
(75, 'El P\'itano', 'ramal 2', 34, 2, 68, 1.73, 1.73, 'sin descripciµn', '1', 'null', 7958),
(76, 'La Caþa', 'ramal 2', 35, 2, 69, 1.54, 1.54, 'sin descripciµn', '1', 'null', 7084),
(77, 'La Huaba', 'ramal 2', 36, 2, 70, 1.41, 1.41, 'sin descripciµn', '1', 'null', 6486),
(78, 'El Algarrobo', 'ramal 2', 37, 2, 71, 0.52, 0.52, 'sin descripciµn', '1', 'null', 2392),
(79, 'El Laurel', 'ramal 2', 38, 2, 72, 1.47, 1.47, 'sin descripciµn', '1', 'null', 6762),
(80, 'La Huayaba', 'ramal 2', 39, 2, 73, 1.5, 1.5, 'sin descripciµn', '1', 'null', 6900),
(81, 'El FrÕjol', 'ramal 2', 40, 2, 74, 1.68, 1.68, 'sin descripciµn', '1', 'null', 7728),
(82, 'La Taya', 'ramal 2', 41, 2, 75, 1.65, 1.65, 'sin descripciµn', '1', 'null', 7590),
(83, 'Jesºs', 'ramal 2', 42, 2, 76, 3.98, 3.98, 'sin descripciµn', '1', 'null', 18308),
(84, 'El Roclo', 'ramal 2', 43, 2, 77, 5, 3, 'sin descripciµn', '1', 'null', 13800),
(85, 'El Pacayal A', 'ramal 2', 44, 2, 78, 5.76, 3, 'sin descripciµn', '1', 'null', 13800),
(86, 'El Pacayal B', 'ramal 2', 45, 2, 78, 4.48, 3, 'sin descripciµn', '1', 'null', 13800),
(87, 'Lucero', 'ramal 2', 46, 2, 19, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(88, 'El Espino', 'ramal 2', 47, 2, 79, 4.98, 3, 'sin descripciµn', '1', 'null', 13800),
(89, 'la Granja', 'ramal 2', 48, 2, 80, 5.13, 5.13, 'sin descripciµn', '1', 'null', 23598),
(90, 'Los Rosales', 'ramal 2', 49, 2, 81, 4.94, 4.94, 'sin descripciµn', '1', 'null', 22724),
(91, 'Don Pedrito', 'ramal 2', 50, 2, 82, 1.96, 1.96, 'sin descripciµn', '1', 'null', 9016),
(92, 'El Mango', 'ramal 2', 51, 2, 2, 4.98, 3, 'sin descripciµn', '1', 'null', 13800),
(93, 'Los Girasoles', 'ramal 2', 52, 2, 83, 5.07, 3, 'sin descripciµn', '1', 'null', 13800),
(94, 'Pampa Hermosa', 'ramal 2', 53, 2, 84, 3.28, 3.28, 'sin descripciµn', '1', 'null', 15088),
(95, 'Parcela 125', 'ramal 2', 54, 2, 85, 1.53, 1.53, 'sin descripciµn', '1', 'null', 7038),
(96, 'El Algarrobo', 'ramal 2', 55, 2, 15, 4.87, 4.87, 'sin descripciµn', '1', 'null', 22402),
(97, 'La 30', 'ramal 2', 56, 2, 86, 4.98, 2, 'sin descripciµn', '1', 'null', 9200),
(98, 'La Granada', 'ramal 2', 57, 2, 87, 4.89, 4.89, 'sin descripciµn', '1', 'null', 22494),
(99, 'La Ciruela', 'ramal 2', 58, 2, 88, 0, 5.03, 'sin descripciµn', '1', 'null', 23138),
(100, 'El Algarrobo', 'ramal 2', 59, 2, 78, 5.42, 5.42, 'sin descripciµn', '1', 'null', 24932),
(101, 'El Triangulo', 'ramal 2', 60, 2, 89, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(102, 'El Rancho del TÚo Benny', 'ramal 2', 61, 2, 90, 5.02, 5.02, 'sin descripciµn', '1', 'null', 23092),
(103, 'La TÚa FelÃ 2', 'ramal 2', 62, 2, 41, 3.87, 3.87, 'sin descripciµn', '1', 'null', 17802),
(104, 'Los Cocos', 'ramal 2', 63, 2, 91, 5.1, 5.1, 'sin descripciµn', '1', 'null', 23460),
(105, 'La Cana', 'ramal 2', 64, 2, 92, 2.01, 2.01, 'sin descripciµn', '1', 'null', 9246),
(106, 'El ParaÚso', 'ramal 2', 65, 2, 27, 1.94, 1.94, 'sin descripciµn', '1', 'null', 8924),
(107, 'Bella Vista', 'ramal 2', 66, 2, 45, 4.05, 4.05, 'sin descripciµn', '1', 'null', 18630),
(108, 'Allana', 'ramal 2', 67, 2, 31, 3.89, 3, 'sin descripciµn', '1', 'null', 13800),
(109, 'Los Guabos', 'ramal 2', 68, 2, 93, 2.84, 2.84, 'sin descripciµn', '1', 'null', 13064),
(110, 'Franco', 'ramal 2', 69, 2, 94, 4.37, 4.37, 'sin descripciµn', '1', 'null', 20102),
(111, 'El Mirador', 'ramal 2', 70, 2, 95, 5.03, 5.03, 'sin descripciµn', '1', 'null', 23138),
(112, 'El Mirador', 'ramal 2', 71, 2, 96, 5.61, 5.61, 'sin descripciµn', '1', 'null', 25806),
(113, 'El Mirador', 'ramal 2', 72, 2, 97, 1.8, 1.8, 'sin descripciµn', '1', 'null', 8280),
(114, 'El Porvenir', 'ramal 2', 73, 2, 98, 2.32, 2.32, 'sin descripciµn', '1', 'null', 10672),
(115, 'El Mirador', 'ramal 2', 74, 2, 99, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(116, 'Palmera I', 'ramal 2', 75, 2, 37, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(117, 'Las Palmeras II', 'ramal 2', 76, 2, 100, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(118, 'La Huaba', 'ramal 2', 77, 2, 101, 1.92, 1.92, 'sin descripciµn', '1', 'null', 8832),
(119, 'la Palta', 'ramal 2', 78, 2, 13, 2.06, 2.06, 'sin descripciµn', '1', 'null', 9476),
(120, 'El Mamey', 'ramal 2', 79, 2, 102, 3.89, 3.89, 'sin descripciµn', '1', 'null', 17894),
(121, 'Perla Verde', 'ramal 2', 80, 2, 52, 4.09, 4.09, 'sin descripciµn', '1', 'null', 18814),
(122, 'la Naranja', 'ramal 2', 81, 2, 103, 4.01, 4.01, 'sin descripciµn', '1', 'null', 18446),
(123, 'El Algarrobo', 'ramal 2', 82, 2, 104, 8.36, 5, 'sin descripciµn', '1', 'null', 23000),
(124, 'La Libertad', 'ramal 2', 83, 2, 105, 22, 22, 'sin descripciµn', '1', 'null', 98200),
(125, 'Las Gemelas', 'ramal 2', 84, 2, 106, 4.04, 4, 'sin descripciµn', '1', 'null', 18400),
(126, 'El Naranjal', 'ramal 2', 85, 2, 28, 3.95, 3.95, 'sin descripciµn', '1', 'null', 18170),
(127, 'El Cerro', 'ramal 2', 86, 2, 48, 4.74, 4.74, 'sin descripciµn', '1', 'null', 21804),
(128, 'Las Brisas', 'ramal 2', 87, 2, 107, 4.3, 4.9, 'sin descripciµn', '1', 'null', 18400),
(129, 'La Piscina', 'ramal 2', 88, 2, 108, 3.57, 3, 'sin descripciµn', '1', 'null', 13800),
(130, 'San Javier', 'ramal 3', 1, 3, 109, 5.01, 5.01, 'sin descripciµn', '1', 'null', 23046),
(131, 'La Guaba', 'ramal 3', 2, 3, 110, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(132, 'Parcela N\' 58 A', 'ramal 3', 3, 3, 111, 0.8, 0.8, 'sin descripciµn', '1', 'null', 3680),
(133, 'Parcela N* 58 B', 'ramal 3', 4, 3, 111, 4.2, 4.2, 'sin descripciµn', '1', 'null', 19320),
(134, 'Parcela N* 59 A', 'ramal 3', 5, 3, 113, 1.98, 1.98, 'sin descripciµn', '1', 'null', 9108),
(135, 'Parcela N* 59 B', 'ramal 3', 6, 3, 113, 3.02, 3.02, 'sin descripciµn', '1', 'null', 13892),
(136, 'Parcela N* 60 A', 'ramal 3', 7, 3, 112, 2.47, 2.47, 'sin descripciµn', '1', 'null', 11362),
(137, 'Parcela N* 60 B', 'ramal 3', 8, 3, 112, 2.58, 2.58, 'sin descripciµn', '1', 'null', 11868),
(138, 'Parcela N* 80', 'ramal 3', 9, 3, 113, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(139, 'Parcela N* 79', 'ramal 3', 10, 3, 113, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(140, 'Parcela N* 78', 'ramal 3', 11, 3, 113, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(141, 'Parcela N* 77', 'ramal 3', 12, 3, 113, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(142, '\"Parcela N\"\" 74\"', 'ramal 3', 13, 3, 113, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(143, 'Parcela N* 73', 'ramal 3', 14, 3, 113, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(144, 'Parcela N\' 71', 'ramal 3', 15, 3, 113, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(145, 'Parcela N* 33', 'ramal 3', 16, 3, 113, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(146, 'Parcela N* 34', 'ramal 3', 17, 3, 113, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(147, 'Claudia', 'ramal 3', 18, 3, 114, 2.86, 2.86, 'sin descripciµn', '1', 'null', 13156),
(148, 'La 72', 'ramal 3', 19, 3, 115, 2.27, 2.27, 'sin descripciµn', '1', 'null', 10442),
(149, 'Ana Myle', 'ramal 3', 20, 3, 35, 10.02, 10.02, 'sin descripciµn', '1', 'null', 46092),
(150, 'Los Platanales B', 'ramal 3', 21, 3, 57, 0.96, 0.96, 'sin descripciµn', '1', 'null', 4416),
(151, 'Los Platanales A', 'ramal 3', 22, 3, 57, 0.72, 0.72, 'sin descripciµn', '1', 'null', 3312),
(152, 'El Platanal A', 'ramal 3', 23, 3, 116, 1.93, 1.93, 'sin descripciµn', '1', 'null', 8878),
(153, 'El Platanal B', 'ramal 3', 24, 3, 116, 0.76, 0.76, 'sin descripciµn', '1', 'null', 3496),
(154, 'Santa Rosa', 'ramal 3', 25, 3, 117, 0.73, 0.73, 'sin descripciµn', '1', 'null', 3358),
(155, 'La Taya', 'ramal 3', 26, 3, 108, 1.9, 1.9, 'sin descripciµn', '1', 'null', 8740),
(156, 'El Manantial B', 'ramal 3', 27, 3, 118, 0.43, 0.43, 'sin descripciµn', '1', 'null', 1978),
(157, 'El Manantial A', 'ramal 3', 28, 3, 118, 4.62, 4.62, 'sin descripciµn', '1', 'null', 21252),
(158, 'La Taya 2', 'ramal 3', 29, 3, 108, 2.99, 2.99, 'sin descripciµn', '1', 'null', 13754),
(159, 'La Esperanza', 'ramal 3', 30, 3, 119, 3.14, 3.14, 'sin descripciµn', '1', 'null', 14444),
(160, 'Las Moringas', 'ramal 3', 31, 3, 120, 5.05, 5.05, 'sin descripciµn', '1', 'null', 23230),
(161, 'El Laurel', 'ramal 3', 32, 3, 121, 1.04, 1.04, 'sin descripciµn', '1', 'null', 4784),
(162, 'El Laurel', 'ramal 3', 33, 3, 122, 1.2, 1.2, 'sin descripciµn', '1', 'null', 5520),
(163, 'La Esperanza', 'ramal 3', 34, 3, 123, 4.68, 4.68, 'sin descripciµn', '1', 'null', 21528),
(164, 'Manolo', 'ramal 3', 35, 3, 124, 4.27, 4.27, 'sin descripciµn', '1', 'null', 19642),
(165, 'Las Brisas', 'ramal 3', 36, 3, 125, 5.11, 5, 'sin descripciµn', '1', 'null', 23000),
(166, 'Las Casuarinas', 'ramal 3', 37, 3, 126, 4.44, 4.44, 'sin descripciµn', '1', 'null', 20424),
(167, 'Las Casuarinas', 'ramal 3', 38, 3, 127, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(168, 'El Pino', 'ramal 3', 39, 3, 128, 2.37, 2.37, 'sin descripciµn', '1', 'null', 10902),
(169, 'El Algarrobo', 'ramal 3', 40, 3, 129, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(170, 'El Alfalfar', 'ramal 3', 41, 3, 130, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(171, 'Campo Verde', 'ramal 3', 42, 3, 131, 4.88, 4.88, 'sin descripciµn', '1', 'null', 22448),
(172, 'Don Juan', 'ramal 3', 43, 3, 132, 1.12, 1.12, 'sin descripciµn', '1', 'null', 5152),
(173, 'la Hierba Santa', 'ramal 3', 44, 3, 133, 4.7, 4, 'sin descripciµn', '1', 'null', 18400),
(174, 'El Sauce', 'ramal 3', 45, 3, 134, 2, 2, 'sin descripciµn', '1', 'null', 9200),
(175, 'Fundo Greda', 'ramal 3', 46, 3, 135, 3.8, 3, 'sin descripciµn', '1', 'null', 13800),
(176, 'La Fortuna', 'ramal 3', 47, 3, 136, 3.44, 3.44, 'sin descripciµn', '1', 'null', 15824),
(177, 'El Pacay', 'ramal 3', 48, 3, 137, 2.61, 2.61, 'sin descripciµn', '1', 'null', 12006),
(178, 'La Guaripera', 'ramal 3', 49, 3, 138, 4.92, 4.92, 'sin descripciµn', '1', 'null', 22632),
(179, 'Las Tayas', 'ramal 3', 50, 3, 139, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(180, 'Los Cocos', 'ramal 3', 51, 3, 91, 5, 5, 'sin descripciµn', '1', 'null', 23000),
(181, 'La Palta', 'ramal 3', 52, 3, 140, 1.55, 1.55, 'sin descripciµn', '1', 'null', 7130),
(182, 'Pajarobobo', 'ramal 3', 53, 3, 141, 1.14, 1.14, 'sin descripciµn', '1', 'null', 5244),
(183, 'Ariana', 'ramal 3', 54, 3, 142, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(184, 'Hualgayoc', 'ramal 3', 55, 3, 143, 15, 15, 'sin descripciµn', '1', 'null', 69000),
(185, 'El Rejo', 'ramal 3', 56, 3, 144, 2.55, 2.55, 'sin descripciµn', '1', 'null', 11730),
(186, 'Los PÚa taþos', 'ramal 3', 57, 3, 145, 1.83, 1.83, 'sin descripciµn', '1', 'null', 8418),
(187, 'El Algarrobo', 'ramal 3', 58, 3, 146, 2.96, 2.96, 'sin descripciµn', '1', 'null', 13616),
(188, 'La Almendra', 'ramal 3', 59, 3, 147, 2.05, 2, 'sin descripciµn', '1', 'null', 9200),
(189, 'La Parcela 62', 'ramal 3', 60, 3, 148, 3.95, 3.95, 'sin descripciµn', '1', 'null', 18170),
(190, 'El Algarrobo', 'ramal 3', 61, 3, 149, 1.94, 1.94, 'sin descripciµn', '1', 'null', 8924),
(191, 'Aldemar', 'ramal 3', 62, 3, 46, 4.11, 4.11, 'sin descripciµn', '1', 'null', 18906),
(192, 'Lla 69', 'ramal 3', 63, 3, 150, 4, 4, 'sin descripciµn', '1', 'null', 18400),
(193, 'La 38', 'ramal 3', 64, 3, 151, 1.62, 1.62, 'sin descripciµn', '1', 'null', 7452),
(194, 'La 63 A', 'ramal 3', 65, 3, 149, 3.79, 3.79, 'sin descripciµn', '1', 'null', 17434),
(195, 'La 63 8', 'ramal 3', 66, 3, 149, 1.15, 1.15, 'sin descripciµn', '1', 'null', 5290),
(196, 'Los Pozos', 'ramal 3', 67, 3, 152, 2.83, 2.5, 'sin descripciµn', '1', 'null', 11500),
(197, 'Santana', 'ramal 3', 68, 3, 105, 10, 10, 'sin descripciµn', '1', 'null', 46000),
(198, 'La 44', 'ramal 3', 69, 3, 146, 3.78, 3.78, 'sin descripciµn', '1', 'null', 17388),
(199, 'Las Compuertas', 'ramal 3', 70, 3, 148, 3.95, 3.95, 'sin descripciµn', '1', 'null', 18170),
(200, 'El Algarrobo I', 'ramal 3', 71, 3, 153, 2, 2, 'sin descripciµn', '1', 'null', 9200),
(201, 'El Desaguadero', 'ramal 3', 72, 3, 148, 3.07, 3.07, 'sin descripciµn', '1', 'null', 14122),
(202, 'Los Espinos', 'ramal 3', 73, 3, 154, 2, 2, 'sin descripciµn', '1', 'null', 9200),
(203, 'El Algarrobo II', 'ramal 3', 74, 3, 155, 1, 1, 'sin descripciµn', '1', 'null', 4600),
(204, 'La Casita de Ladrino', 'ramal 3', 75, 3, 156, 4.62, 4.62, 'sin descripciµn', '1', 'null', 21252),
(205, 'La Costa Verde', 'ramal 3', 76, 3, 157, 3.2, 3.2, 'sin descripciµn', '1', 'null', 14720),
(206, 'Las Tres Guabas', 'ramal 4', 1, 4, 158, 2.6, 2.6, 'sin descripciµn', '1', 'null', 11960),
(207, 'El Sendero', 'ramal 4', 2, 4, 125, 0.92, 0.92, 'sin descripciµn', '1', 'null', 4232),
(208, 'El Tamarindo', 'ramal 4', 3, 4, 108, 3.74, 3, 'sin descripciµn', '1', 'null', 13800),
(209, 'Carmelita', 'ramal 4', 4, 4, 159, 4.96, 3, 'sin descripciµn', '1', 'null', 13800),
(210, 'El Eucalipto', 'ramal 4', 5, 4, 160, 3.94, 3.94, 'sin descripciµn', '1', 'null', 18124),
(211, 'El Eucalipto', 'ramal 4', 6, 4, 148, 2, 2, 'sin descripciµn', '1', 'null', 9200),
(212, 'Los Huabos', 'ramal 4', 7, 4, 148, 4.18, 4.18, 'sin descripciµn', '1', 'null', 19228),
(213, 'Ariana', 'ramal 4', 8, 4, 142, 3, 3, 'sin descripciµn', '1', 'null', 13800),
(214, 'El Algarrobo', 'ramal 4', 9, 4, 149, 2, 2, 'sin descripciµn', '1', 'null', 9200),
(215, 'La Granada', 'ramal 4', 10, 4, 32, 2.03, 2.03, 'sin descripciµn', '1', 'null', 9338),
(216, 'Campo Mar', 'ramal 4', 11, 4, 161, 3.91, 3.91, 'sin descripciµn', '1', 'null', 17986),
(217, 'La 61', 'ramal 4', 12, 4, 162, 3.95, 3.95, 'sin descripciµn', '1', 'null', 18170),
(218, 'La Guaba', 'ramal 4', 13, 4, 155, 1.19, 1.19, 'sin descripciµn', '1', 'null', 5474),
(219, 'La Hacienda SÃnchez', 'ramal 4', 14, 4, 153, 2.44, 2.44, 'sin descripciµn', '1', 'null', 11224),
(220, 'La Papaya', 'ramal 5', 1, 5, 165, 4.63, 4, 'sin descripciµn', '1', 'null', 18400),
(221, 'La Paltµ', 'ramal 5', 2, 5, 166, 1.83, 1.83, 'sin descripciµn', '2', 'null', 8418),
(222, 'El Milagro', 'ramal 5', 3, 5, 167, 3.75, 3, 'sin descripciµn', '3', 'null', 13800),
(223, 'Las Delicias', 'ramal 5', 4, 5, 168, 4, 2, 'sin descripciµn', '4', 'null', 9200),
(224, 'El Pino', 'ramal 5', 5, 5, 165, 3.94, 3.94, 'sin descripciµn', '5', 'null', 18124),
(225, 'La MaracuyÃ', 'ramal 5', 6, 5, 20, 4.01, 4, 'sin descripciµn', '6', 'null', 18400),
(226, 'La Guayaba', 'ramal 5', 7, 5, 20, 3.83, 3.83, 'sin descripciµn', '7', 'null', 17618),
(227, 'Nºmero 42', 'ramal 5', 8, 5, 169, 4.43, 4.43, 'sin descripciµn', '8', 'null', 20378),
(228, 'El EdÕn', 'ramal 5', 9, 5, 170, 4.55, 4.55, 'sin descripciµn', '9', 'null', 20930),
(229, 'La Pampa', 'ramal 5', 10, 5, 171, 3.9, 3.9, 'sin descripciµn', '10', 'null', 17940),
(230, 'Las Flores', 'ramal 5', 11, 5, 172, 3.97, 3.97, 'sin descripciµn', '11', 'null', 18262),
(231, 'El Manuel', 'ramal 5', 12, 5, 173, 5.51, 5.51, 'sin descripciµn', '12', 'null', 25346),
(232, 'Los Algarrobos', 'ramal 5', 13, 5, 174, 3.77, 3.77, 'sin descripciµn', '13', 'null', 17342),
(233, 'Platanal', 'ramal 5', 14, 5, 175, 0.84, 0.84, 'sin descripciµn', '14', 'null', 3864),
(234, 'La Granada', 'ramal 5', 15, 5, 176, 0.97, 0.97, 'sin descripciµn', '15', 'null', 4462),
(235, 'El Espino', 'ramal 5', 16, 5, 177, 1, 1, 'sin descripciµn', '16', 'null', 4462),
(236, 'El Zapotal', 'ramal 5', 17, 5, 178, 5, 5, 'sin descripciµn', '17', 'null', 23000),
(237, 'LosJasmines', 'ramal 5', 18, 5, 179, 1.03, 1.03, 'sin descripciµn', '18', 'null', 4738),
(238, 'El Guabo A', 'ramal 5', 19, 5, 180, 1.24, 1.24, 'sin descripciµn', '19', 'null', 5704),
(239, 'El Guabo B', 'ramal 5', 20, 5, 180, 0.33, 0.33, 'sin descripciµn', '20', 'null', 1518),
(240, 'La Bocana', 'ramal 5', 21, 5, 181, 3.5, 3.5, 'sin descripciµn', '21', 'null', 16100),
(241, 'Maquiabelo', 'ramal 5', 22, 5, 182, 6.02, 6.02, 'sin descripciµn', '22', 'null', 27692),
(242, 'Parcela 84', 'ramal 5', 23, 5, 183, 4.8, 4.8, 'sin descripciµn', '23', 'null', 22080),
(243, 'El Triunfo A', 'ramal 5', 24, 5, 123, 2.75, 2.75, 'sin descripciµn', '24', 'null', 12650),
(244, 'El Triunfo B', 'ramal 5', 25, 5, 123, 5.08, 5.08, 'sin descripciµn', '25', 'null', 23368),
(245, 'El Chilo', 'ramal 5', 26, 5, 17, 5, 5, 'sin descripciµn', '26', 'null', 23000),
(246, 'Las Moradas', 'ramal 5', 27, 5, 184, 3.02, 3.02, 'sin descripciµn', '27', 'null', 13892),
(247, 'El Eucalipto', 'ramal 5', 28, 5, 185, 1.84, 1.84, 'sin descripciµn', '28', 'null', 8464),
(248, 'El Alfalfar', 'ramal 5', 29, 5, 186, 4, 4, 'sin descripciµn', '29', 'null', 18400),
(249, 'La Merced', 'ramal 5', 30, 5, 187, 4, 1, 'sin descripciµn', '30', 'null', 4600),
(250, 'La Pradera', 'ramal 5', 31, 5, 188, 5.06, 5.06, 'sin descripciµn', '31', 'null', 23276),
(251, 'Los Eucaliptos', 'ramal 5', 32, 5, 189, 1.01, 1.01, 'sin descripciµn', '32', 'null', 4646),
(252, 'Jennery Jesibell', 'ramal 5', 33, 5, 190, 1.87, 1.87, 'sin descripciµn', '33', 'null', 8602),
(253, 'Dos Hermanos', 'ramal 5', 34, 5, 191, 1, 1, 'sin descripciµn', '34', 'null', 4600),
(254, 'Los Guabos ', 'ramal 5', 35, 5, 192, 1, 1, 'sin descripciµn', '35', 'null', 0),
(255, 'La Curva', 'ramal 5', 36, 5, 128, 1.79, 1.79, 'sin descripciµn', '36', 'null', 8234),
(256, 'La Caþa', 'ramal 5', 37, 5, 193, 2.27, 2.27, 'sin descripciµn', '37', 'null', 10442),
(257, 'Parcela 56', 'ramal 5', 38, 5, 18, 3.78, 3.78, 'sin descripciµn', '38', 'null', 17388),
(258, 'El Refugio 87', 'ramal 5', 39, 5, 194, 5, 5, 'sin descripciµn', '39', 'null', 23000),
(259, 'El Salvador', 'ramal 5', 40, 5, 152, 1.84, 1.84, 'sin descripciµn', '40', 'null', 8464),
(260, 'Los Pozos', 'ramal 5', 41, 5, 152, 2.83, 2.83, 'sin descripciµn', '41', 'null', 13018);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reparto`
--

CREATE TABLE `reparto` (
  `id_reparto` int(11) NOT NULL,
  `descripcion` varchar(500) COLLATE hp8_bin DEFAULT NULL,
  `tipo` varchar(15) COLLATE hp8_bin DEFAULT NULL,
  `fecha_registro` date DEFAULT NULL,
  `fecha_reparto` date DEFAULT NULL,
  `hora_reparto` time DEFAULT NULL,
  `estado` varchar(1) COLLATE hp8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

--
-- Volcado de datos para la tabla `reparto`
--

INSERT INTO `reparto` (`id_reparto`, `descripcion`, `tipo`, `fecha_registro`, `fecha_reparto`, `hora_reparto`, `estado`) VALUES
(4, 'Esta se guardará', 'General', '2018-11-09', '2019-08-02', '16:30:00', '3'),
(7, 'dsaDS', 'Para Chayas', '2018-11-07', '2019-08-05', '12:12:00', '3'),
(8, NULL, 'Especial', '2018-11-10', '2018-11-11', NULL, '3'),
(9, 'Lo cerramos.', 'General', '2018-11-22', '2019-08-02', '12:30:00', '3'),
(10, 'Lo cerramos.', 'General', '2018-11-26', '2019-08-07', '16:40:00', '3'),
(11, 'bbb', 'Especial', '2018-11-26', '2018-11-10', NULL, '3'),
(12, 'w', 'Para Chayas', NULL, '2019-08-02', '12:12:00', '3'),
(13, 'cdasvdssavfssa', 'Para Chayas', NULL, '2019-08-05', '16:30:00', '2'),
(14, 'REALIZADO PARA PRUEBAS DE ESTADO.', 'Para Chayas', NULL, '2019-08-09', '12:30:00', '1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `talonario`
--

CREATE TABLE `talonario` (
  `id_talonario` int(11) NOT NULL,
  `codigo` int(11) DEFAULT NULL,
  `descripcion` varchar(150) COLLATE hp8_bin DEFAULT NULL,
  `primer_ticket` int(11) DEFAULT NULL,
  `cantidad_tickets` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=hp8 COLLATE=hp8_bin;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_futbolistas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_futbolistas` (
`id_parcela` int(11)
,`nombre` varchar(60)
,`ubicacion` varchar(150)
,`num_toma` int(11)
,`id_canal` int(11)
,`id_auth_user` int(11)
,`total_has` double
,`has_sembradas` double
,`descripcion` varchar(100)
,`estado` varchar(15)
,`codigo_predio` varchar(25)
,`volumen_agua` float
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_parcelas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_parcelas` (
`id_parcela` int(11)
,`nombre` varchar(60)
,`ubicacion` varchar(150)
,`num_toma` int(11)
,`id_canal` int(11)
,`id_auth_user` int(11)
,`total_has` double
,`has_sembradas` double
,`descripcion` varchar(100)
,`estado` varchar(15)
,`codigo_predio` varchar(25)
,`volumen_agua` float
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_futbolistas`
--
DROP TABLE IF EXISTS `vista_futbolistas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_futbolistas`  AS  (select `p`.`id_parcela` AS `id_parcela`,`p`.`nombre` AS `nombre`,`p`.`ubicacion` AS `ubicacion`,`p`.`num_toma` AS `num_toma`,`p`.`id_canal` AS `id_canal`,`p`.`id_auth_user` AS `id_auth_user`,`p`.`total_has` AS `total_has`,`p`.`has_sembradas` AS `has_sembradas`,`p`.`descripcion` AS `descripcion`,`p`.`estado` AS `estado`,`p`.`codigo_predio` AS `codigo_predio`,`p`.`volumen_agua` AS `volumen_agua` from (`parcela` `p` join `canal` `c` on((`p`.`id_canal` = `c`.`id_canal`))) where (`c`.`id_canal` = 3)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_parcelas`
--
DROP TABLE IF EXISTS `v_parcelas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_parcelas`  AS  select `p`.`id_parcela` AS `id_parcela`,`p`.`nombre` AS `nombre`,`p`.`ubicacion` AS `ubicacion`,`p`.`num_toma` AS `num_toma`,`p`.`id_canal` AS `id_canal`,`p`.`id_auth_user` AS `id_auth_user`,`p`.`total_has` AS `total_has`,`p`.`has_sembradas` AS `has_sembradas`,`p`.`descripcion` AS `descripcion`,`p`.`estado` AS `estado`,`p`.`codigo_predio` AS `codigo_predio`,`p`.`volumen_agua` AS `volumen_agua` from (`parcela` `p` join `canal` `c` on((`p`.`id_canal` = `c`.`id_canal`))) where (`c`.`id_canal` = 3) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `agenda_asamblea`
--
ALTER TABLE `agenda_asamblea`
  ADD PRIMARY KEY (`id_agenda`),
  ADD KEY `fk_asa_age_idx` (`id_asamblea`);

--
-- Indices de la tabla `archivos_parcela`
--
ALTER TABLE `archivos_parcela`
  ADD PRIMARY KEY (`id_archivos_parcela`),
  ADD KEY `fk_par_arc_idx` (`id_parcela`);

--
-- Indices de la tabla `asamblea`
--
ALTER TABLE `asamblea`
  ADD PRIMARY KEY (`id_asamblea`);

--
-- Indices de la tabla `auth_group`
--
ALTER TABLE `auth_group`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indices de la tabla `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  ADD KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`);

--
-- Indices de la tabla `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`);

--
-- Indices de la tabla `auth_user`
--
ALTER TABLE `auth_user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indices de la tabla `auth_user_groups`
--
ALTER TABLE `auth_user_groups`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_user_groups_user_id_group_id_94350c0c_uniq` (`user_id`,`group_id`),
  ADD KEY `auth_user_groups_group_id_97559544_fk_auth_group_id` (`group_id`);

--
-- Indices de la tabla `auth_user_user_permissions`
--
ALTER TABLE `auth_user_user_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `auth_user_user_permissions_user_id_permission_id_14a6b632_uniq` (`user_id`,`permission_id`),
  ADD KEY `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` (`permission_id`);

--
-- Indices de la tabla `canal`
--
ALTER TABLE `canal`
  ADD PRIMARY KEY (`id_canal`);

--
-- Indices de la tabla `caudal`
--
ALTER TABLE `caudal`
  ADD PRIMARY KEY (`id_caudal`),
  ADD KEY `fk_can_cau_idx` (`id_canal`);

--
-- Indices de la tabla `comite`
--
ALTER TABLE `comite`
  ADD PRIMARY KEY (`id_comite`);

--
-- Indices de la tabla `comprobante`
--
ALTER TABLE `comprobante`
  ADD PRIMARY KEY (`id_comprobante`),
  ADD KEY `fk_tal_comp_idx` (`id_talonario`);

--
-- Indices de la tabla `comp_multa`
--
ALTER TABLE `comp_multa`
  ADD PRIMARY KEY (`id_comp_multa`),
  ADD KEY `fk_mul_comp_mul_idx` (`id_multa`),
  ADD KEY `fk_comp_comp_mul_idx` (`id_comprobante`);

--
-- Indices de la tabla `comp_orden`
--
ALTER TABLE `comp_orden`
  ADD PRIMARY KEY (`id_comp_orden`),
  ADD KEY `fk_comp_comp_ord_idx` (`id_comprobante`),
  ADD KEY `fk_ord_comp_ord_idx` (`id_orden`);

--
-- Indices de la tabla `datos_personales`
--
ALTER TABLE `datos_personales`
  ADD PRIMARY KEY (`id_datos_personales`),
  ADD KEY `id_auth_user` (`id_auth_user`);

--
-- Indices de la tabla `destajo`
--
ALTER TABLE `destajo`
  ADD PRIMARY KEY (`id_destajo`),
  ADD KEY `fk_can_des_idx` (`id_canal`),
  ADD KEY `fk_par_des_idx` (`id_parcela`);

--
-- Indices de la tabla `det_asamb_canal`
--
ALTER TABLE `det_asamb_canal`
  ADD PRIMARY KEY (`id_dt_asmb_canal`),
  ADD KEY `id_dt_asmb_canal` (`id_dt_asmb_canal`),
  ADD KEY `id_canal` (`id_canal`),
  ADD KEY `id_asamblea` (`id_asamblea`);

--
-- Indices de la tabla `det_limpieza`
--
ALTER TABLE `det_limpieza`
  ADD PRIMARY KEY (`id_det_limpieza`),
  ADD KEY `fk_des_det_idx` (`id_destajo`),
  ADD KEY `fk_lim_det_idx` (`id_limpieza`);

--
-- Indices de la tabla `det_lista`
--
ALTER TABLE `det_lista`
  ADD PRIMARY KEY (`id_det_lista`),
  ADD KEY `fk_lis_det_lis_idx` (`id_lista`),
  ADD KEY `id_auth_user` (`id_auth_user`);

--
-- Indices de la tabla `direccion`
--
ALTER TABLE `direccion`
  ADD PRIMARY KEY (`id_direccion`),
  ADD KEY `fk_per_dir_idx` (`id_datos_personales`);

--
-- Indices de la tabla `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  ADD KEY `django_admin_log_user_id_c564eba6_fk_auth_user_id` (`user_id`);

--
-- Indices de la tabla `django_content_type`
--
ALTER TABLE `django_content_type`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`);

--
-- Indices de la tabla `django_migrations`
--
ALTER TABLE `django_migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `django_session`
--
ALTER TABLE `django_session`
  ADD PRIMARY KEY (`session_key`),
  ADD KEY `django_session_expire_date_a5c62663` (`expire_date`);

--
-- Indices de la tabla `hoja_asistencia`
--
ALTER TABLE `hoja_asistencia`
  ADD PRIMARY KEY (`id_hoja_asistencia`),
  ADD KEY `fk_asam_asis_idx` (`id_asamblea`),
  ADD KEY `id_auth_user` (`id_auth_user`);

--
-- Indices de la tabla `limpieza`
--
ALTER TABLE `limpieza`
  ADD PRIMARY KEY (`id_limpieza`);

--
-- Indices de la tabla `lista`
--
ALTER TABLE `lista`
  ADD PRIMARY KEY (`id_lista`),
  ADD KEY `fk_com_lis_idx` (`id_comite`);

--
-- Indices de la tabla `multa`
--
ALTER TABLE `multa`
  ADD PRIMARY KEY (`id_multa`);

--
-- Indices de la tabla `multa_asistencia`
--
ALTER TABLE `multa_asistencia`
  ADD PRIMARY KEY (`id_multa_asistencia`),
  ADD KEY `fk_mul_asis_idx` (`id_multa`),
  ADD KEY `fk_asi_mul_asi_idx` (`id_hoja_asistencia`);

--
-- Indices de la tabla `multa_limpia`
--
ALTER TABLE `multa_limpia`
  ADD PRIMARY KEY (`id_multa_limpia`),
  ADD KEY `fk_mul_mul_lim_idx` (`id_multa`),
  ADD KEY `fk_det_lim_mul_lim_idx` (`id_det_limpia`);

--
-- Indices de la tabla `multa_orden`
--
ALTER TABLE `multa_orden`
  ADD PRIMARY KEY (`id_multa_orden`),
  ADD KEY `fk_mul_ord_idx` (`id_orden`),
  ADD KEY `fk_mul_mul_ord_idx` (`id_multa`);

--
-- Indices de la tabla `noticia`
--
ALTER TABLE `noticia`
  ADD PRIMARY KEY (`id_noticia`);

--
-- Indices de la tabla `obra`
--
ALTER TABLE `obra`
  ADD PRIMARY KEY (`id_obra`),
  ADD KEY `fk_can_obr_idx` (`id_canal`);

--
-- Indices de la tabla `orden_riego`
--
ALTER TABLE `orden_riego`
  ADD PRIMARY KEY (`id_orden_riego`),
  ADD KEY `fk_rep_ord_idx` (`id_reparto`),
  ADD KEY `fk_par_ord_idx` (`id_parcela`);

--
-- Indices de la tabla `parcela`
--
ALTER TABLE `parcela`
  ADD PRIMARY KEY (`id_parcela`),
  ADD KEY `fk_can_par_idx` (`id_canal`),
  ADD KEY `id_auth_user` (`id_auth_user`);

--
-- Indices de la tabla `reparto`
--
ALTER TABLE `reparto`
  ADD PRIMARY KEY (`id_reparto`);

--
-- Indices de la tabla `talonario`
--
ALTER TABLE `talonario`
  ADD PRIMARY KEY (`id_talonario`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `agenda_asamblea`
--
ALTER TABLE `agenda_asamblea`
  MODIFY `id_agenda` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT de la tabla `archivos_parcela`
--
ALTER TABLE `archivos_parcela`
  MODIFY `id_archivos_parcela` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `asamblea`
--
ALTER TABLE `asamblea`
  MODIFY `id_asamblea` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=72;

--
-- AUTO_INCREMENT de la tabla `auth_group`
--
ALTER TABLE `auth_group`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auth_permission`
--
ALTER TABLE `auth_permission`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=198;

--
-- AUTO_INCREMENT de la tabla `auth_user`
--
ALTER TABLE `auth_user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=195;

--
-- AUTO_INCREMENT de la tabla `auth_user_groups`
--
ALTER TABLE `auth_user_groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `auth_user_user_permissions`
--
ALTER TABLE `auth_user_user_permissions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `canal`
--
ALTER TABLE `canal`
  MODIFY `id_canal` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `caudal`
--
ALTER TABLE `caudal`
  MODIFY `id_caudal` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `comite`
--
ALTER TABLE `comite`
  MODIFY `id_comite` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `comprobante`
--
ALTER TABLE `comprobante`
  MODIFY `id_comprobante` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `comp_multa`
--
ALTER TABLE `comp_multa`
  MODIFY `id_comp_multa` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `comp_orden`
--
ALTER TABLE `comp_orden`
  MODIFY `id_comp_orden` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `datos_personales`
--
ALTER TABLE `datos_personales`
  MODIFY `id_datos_personales` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `destajo`
--
ALTER TABLE `destajo`
  MODIFY `id_destajo` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `det_asamb_canal`
--
ALTER TABLE `det_asamb_canal`
  MODIFY `id_dt_asmb_canal` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT de la tabla `det_limpieza`
--
ALTER TABLE `det_limpieza`
  MODIFY `id_det_limpieza` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `det_lista`
--
ALTER TABLE `det_lista`
  MODIFY `id_det_lista` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `direccion`
--
ALTER TABLE `direccion`
  MODIFY `id_direccion` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `django_admin_log`
--
ALTER TABLE `django_admin_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `django_content_type`
--
ALTER TABLE `django_content_type`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=49;

--
-- AUTO_INCREMENT de la tabla `django_migrations`
--
ALTER TABLE `django_migrations`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- AUTO_INCREMENT de la tabla `hoja_asistencia`
--
ALTER TABLE `hoja_asistencia`
  MODIFY `id_hoja_asistencia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5693;

--
-- AUTO_INCREMENT de la tabla `limpieza`
--
ALTER TABLE `limpieza`
  MODIFY `id_limpieza` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `lista`
--
ALTER TABLE `lista`
  MODIFY `id_lista` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `multa`
--
ALTER TABLE `multa`
  MODIFY `id_multa` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `multa_asistencia`
--
ALTER TABLE `multa_asistencia`
  MODIFY `id_multa_asistencia` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `multa_limpia`
--
ALTER TABLE `multa_limpia`
  MODIFY `id_multa_limpia` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `multa_orden`
--
ALTER TABLE `multa_orden`
  MODIFY `id_multa_orden` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `noticia`
--
ALTER TABLE `noticia`
  MODIFY `id_noticia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `obra`
--
ALTER TABLE `obra`
  MODIFY `id_obra` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `orden_riego`
--
ALTER TABLE `orden_riego`
  MODIFY `id_orden_riego` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `parcela`
--
ALTER TABLE `parcela`
  MODIFY `id_parcela` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=261;

--
-- AUTO_INCREMENT de la tabla `reparto`
--
ALTER TABLE `reparto`
  MODIFY `id_reparto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `talonario`
--
ALTER TABLE `talonario`
  MODIFY `id_talonario` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `agenda_asamblea`
--
ALTER TABLE `agenda_asamblea`
  ADD CONSTRAINT `fk_asa_age` FOREIGN KEY (`id_asamblea`) REFERENCES `asamblea` (`id_asamblea`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `archivos_parcela`
--
ALTER TABLE `archivos_parcela`
  ADD CONSTRAINT `fk_par_arc` FOREIGN KEY (`id_parcela`) REFERENCES `parcela` (`id_parcela`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `auth_group_permissions`
--
ALTER TABLE `auth_group_permissions`
  ADD CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`);

--
-- Filtros para la tabla `auth_permission`
--
ALTER TABLE `auth_permission`
  ADD CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`);

--
-- Filtros para la tabla `auth_user_groups`
--
ALTER TABLE `auth_user_groups`
  ADD CONSTRAINT `auth_user_groups_group_id_97559544_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  ADD CONSTRAINT `auth_user_groups_user_id_6a12ed8b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `auth_user_user_permissions`
--
ALTER TABLE `auth_user_user_permissions`
  ADD CONSTRAINT `auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  ADD CONSTRAINT `auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `caudal`
--
ALTER TABLE `caudal`
  ADD CONSTRAINT `fk_can_cau` FOREIGN KEY (`id_canal`) REFERENCES `canal` (`id_canal`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `comprobante`
--
ALTER TABLE `comprobante`
  ADD CONSTRAINT `fk_tal_comp` FOREIGN KEY (`id_talonario`) REFERENCES `talonario` (`id_talonario`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `comp_multa`
--
ALTER TABLE `comp_multa`
  ADD CONSTRAINT `fk_comp_comp_mul` FOREIGN KEY (`id_comprobante`) REFERENCES `comprobante` (`id_comprobante`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_mul_comp_mul` FOREIGN KEY (`id_multa`) REFERENCES `multa` (`id_multa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `comp_orden`
--
ALTER TABLE `comp_orden`
  ADD CONSTRAINT `fk_comp_comp_ord` FOREIGN KEY (`id_comprobante`) REFERENCES `comprobante` (`id_comprobante`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_ord_comp_ord` FOREIGN KEY (`id_orden`) REFERENCES `orden_riego` (`id_orden_riego`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `datos_personales`
--
ALTER TABLE `datos_personales`
  ADD CONSTRAINT `datos_personales_ibfk_1` FOREIGN KEY (`id_auth_user`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `destajo`
--
ALTER TABLE `destajo`
  ADD CONSTRAINT `fk_can_des` FOREIGN KEY (`id_canal`) REFERENCES `canal` (`id_canal`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_par_des` FOREIGN KEY (`id_parcela`) REFERENCES `parcela` (`id_parcela`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `det_asamb_canal`
--
ALTER TABLE `det_asamb_canal`
  ADD CONSTRAINT `det_asamb_canal_ibfk_1` FOREIGN KEY (`id_asamblea`) REFERENCES `asamblea` (`id_asamblea`),
  ADD CONSTRAINT `det_asamb_canal_ibfk_2` FOREIGN KEY (`id_canal`) REFERENCES `canal` (`id_canal`);

--
-- Filtros para la tabla `det_limpieza`
--
ALTER TABLE `det_limpieza`
  ADD CONSTRAINT `fk_des_det` FOREIGN KEY (`id_destajo`) REFERENCES `destajo` (`id_destajo`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_lim_det` FOREIGN KEY (`id_limpieza`) REFERENCES `limpieza` (`id_limpieza`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `det_lista`
--
ALTER TABLE `det_lista`
  ADD CONSTRAINT `det_lista_ibfk_1` FOREIGN KEY (`id_auth_user`) REFERENCES `auth_user` (`id`),
  ADD CONSTRAINT `fk_lis_det_lis` FOREIGN KEY (`id_lista`) REFERENCES `lista` (`id_lista`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `direccion`
--
ALTER TABLE `direccion`
  ADD CONSTRAINT `fk_per_dir` FOREIGN KEY (`id_datos_personales`) REFERENCES `datos_personales` (`id_datos_personales`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `django_admin_log`
--
ALTER TABLE `django_admin_log`
  ADD CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  ADD CONSTRAINT `django_admin_log_user_id_c564eba6_fk_auth_user_id` FOREIGN KEY (`user_id`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `hoja_asistencia`
--
ALTER TABLE `hoja_asistencia`
  ADD CONSTRAINT `fk_asamblea_hoja_asistencia` FOREIGN KEY (`id_asamblea`) REFERENCES `asamblea` (`id_asamblea`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `hoja_asistencia_ibfk_1` FOREIGN KEY (`id_auth_user`) REFERENCES `auth_user` (`id`);

--
-- Filtros para la tabla `lista`
--
ALTER TABLE `lista`
  ADD CONSTRAINT `fk_com_lis` FOREIGN KEY (`id_comite`) REFERENCES `comite` (`id_comite`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `multa_asistencia`
--
ALTER TABLE `multa_asistencia`
  ADD CONSTRAINT `fk_asi_mul_asi` FOREIGN KEY (`id_hoja_asistencia`) REFERENCES `hoja_asistencia` (`id_hoja_asistencia`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_mul_asis` FOREIGN KEY (`id_multa`) REFERENCES `multa` (`id_multa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `multa_limpia`
--
ALTER TABLE `multa_limpia`
  ADD CONSTRAINT `fk_det_lim_mul_lim` FOREIGN KEY (`id_det_limpia`) REFERENCES `det_limpieza` (`id_det_limpieza`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_mul_mul_lim` FOREIGN KEY (`id_multa`) REFERENCES `multa` (`id_multa`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `multa_orden`
--
ALTER TABLE `multa_orden`
  ADD CONSTRAINT `fk_mul_mul_ord` FOREIGN KEY (`id_multa`) REFERENCES `multa` (`id_multa`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_mul_ord` FOREIGN KEY (`id_orden`) REFERENCES `orden_riego` (`id_orden_riego`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `obra`
--
ALTER TABLE `obra`
  ADD CONSTRAINT `fk_can_obr` FOREIGN KEY (`id_canal`) REFERENCES `canal` (`id_canal`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `orden_riego`
--
ALTER TABLE `orden_riego`
  ADD CONSTRAINT `fk_par_ord` FOREIGN KEY (`id_parcela`) REFERENCES `parcela` (`id_parcela`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_rep_ord` FOREIGN KEY (`id_reparto`) REFERENCES `reparto` (`id_reparto`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `parcela`
--
ALTER TABLE `parcela`
  ADD CONSTRAINT `fk_can_par` FOREIGN KEY (`id_canal`) REFERENCES `canal` (`id_canal`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `parcela_ibfk_1` FOREIGN KEY (`id_auth_user`) REFERENCES `auth_user` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
