<?php
header("Content-Type: application/json");


$data = json_decode(file_get_contents("php://input"), true);

if (!isset($data['pid']) || empty($data['pid'])) {
    echo json_encode([
        'status' => 'ERROR',
        'pesan' => 'PID tidak ditemukan atau kosong.'
    ]);
    exit;
}

$pnim = $data['pid'];


include_once("conn.php");


$sql = "CALL hapusMHS(?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $pnim);

if ($stmt->execute()) {

    $result = $stmt->get_result();
    if ($result && $row = $result->fetch_assoc()) {
        echo json_encode([
            'status' => 'SUKSES',
            'pesan' => $row['rpesan'] ?? 'Data berhasil dihapus.'
        ]);
        $result->close();
    } else {
        echo json_encode([
            'status' => 'SUKSES',
            'pesan' => 'Data berhasil dihapus.'
        ]);
    }
} else {
    echo json_encode([
        'status' => 'ERROR',
        'pesan' => 'Error: ' . $stmt->error
    ]);
}


$stmt->close();
$conn->close();
?>
