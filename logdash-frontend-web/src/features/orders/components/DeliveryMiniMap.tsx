import { useEffect, useRef } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import L from 'leaflet';
import type { LocationUpdate } from '../hooks/useDeliveryLocation';
import { useDeliveryLocation } from '../hooks/useDeliveryLocation';

// Corrige o ícone padrão do Leaflet (problema comum com Vite/Webpack)
delete (L.Icon.Default.prototype as unknown as Record<string, unknown>)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
});

const courierIcon = new L.Icon({
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  popupAnchor: [1, -34],
});

function MapUpdater({ location }: { location: LocationUpdate }) {
  const map = useMap();
  const prevRef = useRef<LocationUpdate | null>(null);

  useEffect(() => {
    if (
      prevRef.current?.latitude !== location.latitude ||
      prevRef.current?.longitude !== location.longitude
    ) {
      map.flyTo([location.latitude, location.longitude], map.getZoom(), {
        animate: true,
        duration: 1,
      });
      prevRef.current = location;
    }
  }, [location, map]);

  return null;
}

interface DeliveryMiniMapProps {
  orderId: number;
}

const DEFAULT_CENTER: [number, number] = [-23.5505, -46.6333]; // São Paulo

export default function DeliveryMiniMap({ orderId }: DeliveryMiniMapProps) {
  const { location } = useDeliveryLocation(orderId, true);

  const center: [number, number] = location
    ? [location.latitude, location.longitude]
    : DEFAULT_CENTER;

  return (
    <div className="rounded-xl border border-gray-200/70 bg-white p-6 shadow-[0_12px_30px_-16px_rgba(15,23,42,0.35)]">
      <div className="mb-3 flex items-center gap-2">
        <span className="inline-block w-2.5 h-2.5 rounded-full bg-green-500 animate-pulse" />
        <h2 className="text-sm font-semibold uppercase tracking-wide text-gray-600">
          Localização do Entregador
        </h2>
        {!location && (
          <span className="text-xs text-gray-400 ml-auto">Aguardando sinal...</span>
        )}
      </div>

      <div className="h-56 w-full overflow-hidden rounded-xl border border-gray-200/70">
        <MapContainer
          center={center}
          zoom={15}
          style={{ height: '100%', width: '100%' }}
          scrollWheelZoom={false}
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          {location && (
            <>
              <MapUpdater location={location} />
              <Marker position={[location.latitude, location.longitude]} icon={courierIcon}>
                <Popup>Entregador em movimento</Popup>
              </Marker>
            </>
          )}
        </MapContainer>
      </div>

      {location && (
        <p className="mt-2 text-xs text-gray-400 text-right">
          Atualizado às{' '}
          {new Date(location.timestamp).toLocaleTimeString('pt-BR')}
        </p>
      )}
    </div>
  );
}
