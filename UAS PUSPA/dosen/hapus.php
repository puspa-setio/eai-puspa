<?php
header("Content-Type: application/json");
include("conn.php");


$data = json_decode(file_get_contents("php://input"), true);


if (!isset($data["pid"]) || empty(trim($data["pid"]))) {
    echo json_encode(["status" => "ERROR", "pesan" => "ID dosen tidak valid atau tidak diberikan."]);
    exit;
}

$id_dosen = trim($data["pid"]);


$sql = "CALL hapusDOSEN(?)";
$stmt = $conn->prepare($sql);

if ($stmt) {
    $stmt->bind_param("s", $id_dosen);
    
    if ($stmt->execute()) {
        echo json_encode(["status" => "SUKSES", "pesan" => "Data berhasil dihapus."]);
    } else {
        echo json_encode(["status" => "ERROR", "pesan" => "Gagal menghapus data. Error: " . $stmt->error]);
    }
    
    $stmt->close();
} else {
    echo json_encode(["status" => "ERROR", "pesan" => "Kesalahan dalam persiapan query: " . $conn->error]);
}

$conn->close();
?>
