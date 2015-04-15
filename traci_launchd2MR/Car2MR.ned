//
// Copyright (C) 2006-2012 Christoph Sommer <christoph.sommer@uibk.ac.at>
//
// Documentation for these modules is at http://veins.car2x.org/
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//

package inet.examples.Examples_Inet299.traci_launchd2MR;

import inet.applications.traci.TraCIDemo;
import inet.applications.udpapp.UDPBasicBurst;

import inet.linklayer.ieee80211.Ieee80211Nic;
import inet.mobility.group.TraCIMobility;
import inet.networklayer.common.InterfaceTable;
import inet.networklayer.configurator.ipv4.HostAutoConfigurator;
import inet.networklayer.ipv4.IPv4NetworkLayer;
import inet.networklayer.ipv4.IPv4RoutingTable;
import inet.transportlayer.udp.UDP;
import inet.networklayer.contract.IManetRouting;
import inet.routing.aodv.AODVRouting;
import inet.linklayer.loopback.LoopbackInterface;


module Car2MR
{
    parameters:
        @node();
        @labels(node,ethernet-node,wireless-node);
        //*.mobilityModule = default(absPath(".mobility"));
        **.interfaceTableModule = default(absPath(".interfaceTable"));
        **.routingTableModule = default(absPath(".routingTable"));
        **.networkProtocolModule = default(absPath(".networkLayer.ip"));
        **.icmpModule = default(absPath(".networkLayer.icmp"));

        //string routingProtocol @enum("AODVUU","DYMOUM","DYMO","DSRUU","OLSR","OLSR_ETX","DSDV_2","Batman") = default("");
        int numRadios = default(1);
    gates:
        input radioIn[numRadios] @directIn;

    submodules:
        ac_wlan: HostAutoConfigurator {
            parameters:
                @display("p=60,397");
                interfaces = "wlan0";
        }
        interfaceTable: InterfaceTable {
            parameters:
                @display("p=155,349");
        }
        //        app: TraCIDemo {
        app: UDPBasicBurst {
            parameters:
                @display("p=318,46");
        }
        mobility: TraCIMobility {
            parameters:
                @display("p=60,459");
                traciScenarioManagerModule = default("manager");
        }
        routingTable: IPv4RoutingTable {
            parameters:
                forwarding = true;
                // routerId = "";
                routingFile = "";
                @display("p=60,294");
        }
        udp: UDP {
            parameters:
                @display("p=318,168");
        }
        networkLayer: IPv4NetworkLayer {
            parameters:
                proxyARP = false;
                @display("p=304,327;q=queue");
            gates:
                ifIn[1];
                ifOut[1];
        }
        aodv: AODVRouting {
            @display("p=155,207");
        }
        wlan[numRadios]: Ieee80211Nic {
            parameters:
                @display("p=304,459,row,60;q=queue");
        }
        lo0: LoopbackInterface {
            @display("p=172,461");
        }
    connections allowunconnected:
        udp.appOut++ --> app.udpIn;
        udp.appIn++ <-- app.udpOut;

        udp.ipOut --> networkLayer.transportIn++;
        udp.ipIn <-- networkLayer.transportOut++;

        networkLayer.transportOut++ --> aodv.ipIn;
        networkLayer.transportIn++ <-- aodv.ipOut;

        networkLayer.ifOut++ --> lo0.upperLayerIn;
        lo0.upperLayerOut --> networkLayer.ifIn++;

        for i=0..sizeof(radioIn)-1 {
            radioIn[i] --> { @display("m=s"); } --> wlan[i].radioIn;
            wlan[i].upperLayerOut --> networkLayer.ifIn++;
            wlan[i].upperLayerIn <-- networkLayer.ifOut++;
        }

        //wlan.upperLayerOut --> networkLayer.ifIn[0];
        //wlan.upperLayerIn <-- networkLayer.ifOut[0];

        //radioIn --> wlan.radioIn;

}

