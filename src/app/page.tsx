"use client";
import { useEffect, useState } from "react";
import Image from "next/image";
import { parse } from "csv-parse/browser/esm";

export default function Home() {
  const [graphSrc, setGraphSrc] = useState("/FEEZLY_SpringLayout_Colored.png");
  const [csvData, setCsvData] = useState<any[]>([]);
  const [theme, setTheme] = useState(process.env.NEXT_PUBLIC_THEME || "dark");

  const refresh = () => {
    fetch("/FEEZLY_CortexMap.csv")
      .then((res) => res.text())
      .then((text) => {
        parse(text, { columns: true }, (err, records) => {
          if (!err) setCsvData(records);
        });
      });
    setGraphSrc(`/FEEZLY_SpringLayout_Colored.png?rand=${Date.now()}`);
  };

  useEffect(() => {
    refresh();
    const interval = setInterval(refresh, parseInt(process.env.NEXT_PUBLIC_GRAPH_REFRESH_INTERVAL || "5000"));
    return () => clearInterval(interval);
  }, []);

  return (
    <div style={{ padding: 24, background: theme === "dark" ? "#111" : "#f4f4f4", minHeight: "100vh", color: theme === "dark" ? "#0f0" : "#111" }}>
      <h1 style={{ fontSize: 32, fontWeight: "bold" }}>🧠 FEEZLY Cortex Map</h1>
      <Image src={graphSrc} alt="FEEZLY Graph" width={1000} height={600} />
      <div style={{ marginTop: 20 }}>
        <h2>CSV Preview</h2>
        {csvData.length === 0 ? (
          <div>⏳ Loading...</div>
        ) : (
          <pre style={{ whiteSpace: "pre-wrap", maxHeight: 300, overflowY: "scroll", background: "#222", padding: 10 }}>
            {csvData.map((row, i) => JSON.stringify(row)).join("\n")}
          </pre>
        )}
      </div>
    </div>
  );
}
