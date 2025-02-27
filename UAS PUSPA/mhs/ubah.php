<?php
    header("Content-Type: application/json; charset=UTF-8");
    include_once("conn.php");

    $inputJSON = file_get_contents("php://input");
    $input = json_decode($inputJSON, true);

    if (!$input) {
        echo json_encode(["status" => "ERROR", "pesan" => "Format data tidak valid"]);
        exit();
    }

    $poldnim = $input['poldnim'];
    $nim = $input['nim'];
    $nama = $input['nama'];
    $tempat_lahir = $input['tempat_lahir'];
    $tanggal_lahir = $input['tanggal_lahir'];
    $jenis_kelamin = $input['jenis_kelamin'];
    $masuk = $input['masuk'];
    $keluar = $input['keluar'];

    $query = "CALL ubahMHS(?, ?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("ssssssss", $poldnim, $nim, $nama, $tempat_lahir, $tanggal_lahir, $jenis_kelamin, $masuk, $keluar);

    if ($stmt->execute()) {
        echo json_encode(["status" => "SUKSES", "pesan" => "Data berhasil diubah"]);
    } else {
        echo json_encode(["status" => "ERROR", "pesan" => "Gagal mengubah data"]);
    }

    $stmt->close();
    $conn->close();
?>
