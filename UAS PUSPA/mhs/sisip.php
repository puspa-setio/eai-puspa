<?php
header("Content-Type: application/json");


$inputJSON = file_get_contents("php://input");
$od = json_decode($inputJSON, true);

$response = ["proses" => "SISIP MAHASISWA"];

if (isset($od["nim"]) && !empty($od["nim"])) {
    $nim = $od["nim"] ?? '';
    $nama = $od["nama"] ?? '';
    $tempat_lahir = $od["tempat_lahir"] ?? '';
    $tanggal_lahir = $od["tanggal_lahir"] ?? '';
    $jenis_kelamin = $od["jenis_kelamin"] ?? '';
    $masuk = $od["masuk"] ?? '';
    $keluar = $od["keluar"] ?? '';

    if (!empty($tanggal_lahir)) {
        $tanggal_lahir = date('Y-m-d', strtotime($tanggal_lahir));
    }

    include_once("conn.php");

  
    $sql = "CALL sisipMHS(?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssssss", $nim, $nama, $tempat_lahir, $tanggal_lahir, $jenis_kelamin, $masuk, $keluar);

    if ($stmt->execute()) {
        $response["status"] = "SUKSES";
        $response["pesan"] = "Data tersimpan.";
    } else {
        $response["status"] = "ERROR";
        $response["pesan"] = "Error: " . $stmt->error;
    }

    $stmt->close();
    $conn->close();
} else {
    $response["status"] = "ERROR";
    $response["pesan"] = "Data tidak lengkap atau NIM kosong.";
}

echo json_encode($response, JSON_PRETTY_PRINT);
?>
