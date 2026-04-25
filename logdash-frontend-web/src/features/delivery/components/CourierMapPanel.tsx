import { useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import iconRetinaUrl from 'leaflet/dist/images/marker-icon-2x.png';
import iconUrl from 'leaflet/dist/images/marker-icon.png';
import shadowUrl from 'leaflet/dist/images/marker-shadow.png';
import { useDeliveryLocationWebSocket } from '../hooks/useDeliveryLocationWebSocket';

// Fix Leaflet marker icon paths no Vite
delete (L.Icon.Default.prototype as unknown as Record<string, unknown>)['_getIconUrl'];
L.Icon.Default.mergeOptions({ iconRetinaUrl, iconUrl, shadowUrl });

function RecenterMap({ lat, lng }: { lat: number; lng: number }) {
  const map = useMap();
  useEffect(() => {
    map.setView([lat, lng]);
  }, [lat, lng, map]);
  return null;
}

interface CourierMapPanelProps {
  orderId: number;
}

export default function CourierMapPanel({ orderId }: CourierMapPanelProps) {
  const location = useDeliveryLocationWebSocket(orderId);

  if (!location) {
    return (
      <div className="flex items-center justify-center h-48 bg-gray-50 rounded-lg border border-dashed border-gray-300">
        <div className="text-center text-sm text-gray-500">
          <p className="text-2xl mb-1">&#128205;</p>
          <p>Aguardando localizacao do entregador...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="rounded-lg overflow-hidden border border-gray-200" style={{ height: 240 }}>
      <MapContainer
        center={[location.latitude, location.longitude]}
        zoom={15}
        style={{ height: '100%', width: '100%' }}
        scrollWheelZoom={false}
      >
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        />
        <Marker position={[location.latitude, location.longitude]}>
          <Popup>Entregador</Popup>
        </Marker>
        <RecenterMap lat={location.latitude} lng={location.longitude} />
      </MapContainer>
    </div>
  );
}
