<?php
header("Content-Type: application/json");

include("conn.php");

$filter = isset($_GET['filter']) ? $_GET['filter'] : "";

$sql = "CALL tampilDOSEN(?)";

$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $filter);
$stmt->execute();
$result = $stmt->get_result();

$response = array();
$response["proses"] = "TAMPIL DOSEN";

if ($result->num_rows > 0) {
    $response["data"] = array();
    while ($row = $result->fetch_assoc()) {
        $response["data"][] = array(
            "id_dosen"      => $row["id_dosen"],
            "nama"          => $row["nama"],
            "tempat_lahir"  => $row["tempat_lahir"],
            "tanggal_lahir" => $row["tanggal_lahir"],
            "jenis_kelamin" => $row["jenis_kelamin"],
            "masuk"         => $row["masuk"],
            "keluar"        => $row["keluar"]
        );
    }
    $response["status"] = "SUKSES";
    $response["pesan"] = $result->num_rows . " data ditemukan";
} else {
    $response["status"] = "ERROR";
    $response["pesan"] = "Tidak Ada Data";
}

$stmt->close();
$conn->close();

echo json_encode($response, JSON_PRETTY_PRINT);
?>
