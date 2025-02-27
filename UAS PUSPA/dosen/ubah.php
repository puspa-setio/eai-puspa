<?php
header("Content-Type: application/json");
include("conn.php");


$data = json_decode(file_get_contents("php://input"), true);


if (
    isset($data["poldid_dosen"], $data["id_dosen"], $data["nama"], $data["tempat_lahir"], $data["tanggal_lahir"], 
          $data["jenis_kelamin"], $data["masuk"], $data["keluar"]) 
    && !empty(trim($data["poldid_dosen"])) && !empty(trim($data["id_dosen"])) && !empty(trim($data["nama"]))
) {
  
    $oldid_dosen   = trim($data["poldid_dosen"]);
    $id_dosen      = trim($data["id_dosen"]);
    $nama          = trim($data["nama"]);
    $tempat_lahir  = trim($data["tempat_lahir"]);
    $tanggal_lahir = trim($data["tanggal_lahir"]);
    $jenis_kelamin = trim($data["jenis_kelamin"]);
    $masuk         = trim($data["masuk"]);
    $keluar        = trim($data["keluar"]);

 
    $sql = "CALL ubahDOSEN(?, ?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($sql);

    if ($stmt) {

        $stmt->bind_param("ssssssss", $oldid_dosen, $id_dosen, $nama, $tempat_lahir, $tanggal_lahir, $jenis_kelamin, $masuk, $keluar);

   
        if ($stmt->execute()) {
            echo json_encode(["status" => "SUKSES", "pesan" => "Data berhasil diubah."]);
        } else {
            echo json_encode(["status" => "ERROR", "pesan" => "Gagal mengubah data: " . $stmt->error]);
        }

        $stmt->close();
    } else {
        echo json_encode(["status" => "ERROR", "pesan" => "Kesalahan dalam persiapan query: " . $conn->error]);
    }
} else {
    echo json_encode(["status" => "ERROR", "pesan" => "Data tidak lengkap atau ada yang kosong."]);
}


$conn->close();
?>
