<?php
header("Content-Type: application/json");
include("conn.php");


$data = json_decode(file_get_contents("php://input"), true);


if (
    isset($data["id_dosen"], $data["nama"], $data["tempat_lahir"], 
          $data["tanggal_lahir"], $data["jenis_kelamin"], 
          $data["masuk"], $data["keluar"]) 
    && !empty($data["id_dosen"])
) {

    $id_dosen = $data["id_dosen"];
    $nama = $data["nama"];
    $tempat_lahir = $data["tempat_lahir"];
    $tanggal_lahir = $data["tanggal_lahir"];
    $jenis_kelamin = $data["jenis_kelamin"];
    $masuk = $data["masuk"];
    $keluar = $data["keluar"];

    
    $sql = "CALL sisipDOSEN(?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);

    if ($stmt) {
        $stmt->bind_param("sssssss", $id_dosen, $nama, $tempat_lahir, $tanggal_lahir, $jenis_kelamin, $masuk, $keluar);

        if ($stmt->execute()) {
            echo json_encode(["status" => "SUKSES", "pesan" => "Data berhasil ditambahkan."]);
        } else {
            echo json_encode(["status" => "ERROR", "pesan" => "Gagal menambahkan data: " . $stmt->error]);
        }

        $stmt->close();
    } else {
        echo json_encode(["status" => "ERROR", "pesan" => "Gagal menyiapkan query: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => "ERROR", "pesan" => "Data tidak lengkap."]);
}

$conn->close();
?>
