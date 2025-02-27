<?php
    echo "{\"proses\":\"TAMPIL MAHASISWA\",";

    $filter = "";
    if(isset($od["filter"]) && $od["filter"] != "") {
        $filter = $od["filter"];
    }

    $sql = "CALL tampilMHS('" . $filter . "');";
    include_once("conn.php");

    $result = $conn->query($sql);
    if($result->num_rows > 0) {
        echo "\"data\": [";
        $counter = 0;
        while($row = $result->fetch_assoc()) {
            if($counter > 0) { echo ","; }
            echo "{\"nim\": \"" . $row["nim"] . "\", ";
            echo "\"id\": \"" . $row["id"] . "\", ";
            echo "\"nama\": \"" . $row["nama"] . "\", ";
            echo "\"tempat_lahir\": \"" . $row["tempat_lahir"] . "\", ";
            echo "\"tanggal_lahir\": \"" . $row["tanggal_lahir"] . "\", ";
            echo "\"jenis_kelamin\": \"" . $row["jenis_kelamin"] . "\", ";
            echo "\"masuk\": \"" . $row["masuk"] . "\", ";
            echo "\"keluar\": \"" . $row["keluar"] . "\"}";
            $counter++;
        }
        echo "],";
        echo "\"status\":\"SUKSES\",";
        echo "\"pesan\":\"" . $result->num_rows . " data ditemukan.\"}";
    } else {
        echo "\"status\":\"ERROR\",\"pesan\":\"Tidak Ada Data\"}";
    }

    $conn->close();
?>
