import '../models/billing.dart';
import '../models/customer.dart';
import '../models/plan.dart';
import '../models/ticket.dart';

/// Seed data taken from the current app screens. Plan prices and add-ons are
/// placeholders until the real price list is wired in.
abstract final class MockData {
  static final customer = Customer(
    name: 'Hillary Makori',
    accountNumber: 'SFKL2551',
    username: 'SFKL2551',
    primaryPhone: '+254734222990',
    email: 'htnmakori@gmail.com',
    customerType: 'Prepaid',
    category: 'Silver',
    isActive: true,
    activatedAt: DateTime(2025, 11, 12, 18, 55),
    paymentReminders: true,
    serviceAlerts: true,
    address: const ServiceAddress(
      serviceArea: '04-S-FMTG-13',
      branch: 'Savanna Fibre (KE)',
      latitude: -1.267017088228481,
      longitude: 36.79558930544299,
    ),
  );

  static const plans = <Plan>[
    Plan(
      id: 'complimentary',
      name: 'Complimentary',
      speedMbps: 10,
      priceKes: 0,
      validityDays: 30,
      tagline: 'Your welcome month on us',
    ),
    Plan(
      id: 'lite',
      name: 'Lite',
      speedMbps: 10,
      priceKes: 1500,
      validityDays: 30,
      tagline: 'Browsing, email and HD streaming',
    ),
    Plan(
      id: 'home',
      name: 'Home',
      speedMbps: 20,
      priceKes: 2500,
      validityDays: 30,
      tagline: 'A busy home with a few screens',
      popular: true,
    ),
    Plan(
      id: 'family',
      name: 'Family',
      speedMbps: 50,
      priceKes: 3500,
      validityDays: 30,
      tagline: '4K streaming and video calls at once',
    ),
    Plan(
      id: 'pro',
      name: 'Pro',
      speedMbps: 100,
      priceKes: 5500,
      validityDays: 30,
      tagline: 'Work from home, gaming and big uploads',
    ),
  ];

  static final connection = Connection(id: 'SERV2025-0003903', plan: plans.first, expiresAt: DateTime(2025, 12, 12));

  static const addons = <Addon>[
    Addon(
      id: 'static_ip',
      name: 'Static IP',
      description: 'A fixed public IP for remote access, CCTV and VPNs.',
      priceKes: 500,
      billing: AddonBilling.monthly,
      confirmation: 'Your static IP will be assigned within 2 hours. It renews with your plan.',
    ),
    Addon(
      id: 'mesh',
      name: 'Mesh Wi-Fi point',
      description: "An extra access point for rooms the router can't reach.",
      priceKes: 400,
      billing: AddonBilling.monthly,
      confirmation: "We'll call you to book a delivery and setup visit.",
    ),
    Addon(
      id: 'boost',
      name: 'Speed boost, 24 hours',
      description: 'Double your speed for a day. Handy for big downloads.',
      priceKes: 150,
      billing: AddonBilling.oneOff,
      confirmation: 'Your speed is doubled for the next 24 hours.',
    ),
    Addon(
      id: 'router_upgrade',
      name: 'Wi-Fi 6 router',
      description: 'Swap your router for a faster dual-band Wi-Fi 6 model.',
      priceKes: 2500,
      billing: AddonBilling.oneOff,
      confirmation: "We'll call you to schedule the swap.",
    ),
  ];

  static const wallet = WalletState(balance: 0, transactions: []);

  static final invoices = <Invoice>[
    Invoice(
      id: 'INV-2511-0413',
      title: 'Complimentary plan',
      issuedAt: DateTime(2025, 11, 12),
      periodStart: DateTime(2025, 11, 12),
      periodEnd: DateTime(2025, 12, 12),
      lines: const [InvoiceLine('Complimentary 10 Mbps, 30 days', 0)],
      status: InvoiceStatus.paid,
    ),
    Invoice(
      id: 'INV-2511-0412',
      title: 'Installation and activation',
      issuedAt: DateTime(2025, 11, 12),
      periodStart: DateTime(2025, 11, 12),
      periodEnd: DateTime(2025, 11, 12),
      lines: const [InvoiceLine('Fibre installation', 0), InvoiceLine('Router (on loan)', 0)],
      status: InvoiceStatus.paid,
    ),
  ];

  static final tickets = <Ticket>[
    Ticket(
      id: 'INQ-3993',
      subject: 'Welcome call',
      category: 'Account',
      status: TicketStatus.open,
      createdAt: DateTime(2025, 11, 18, 10, 12),
      followUpAt: DateTime(2025, 11, 20, 13, 39),
      description: 'Courtesy call to check how your new connection is working.',
      events: [
        TicketEvent(title: 'Ticket opened', at: DateTime(2025, 11, 18, 10, 12)),
        TicketEvent(
          title: 'Follow-up scheduled',
          at: DateTime(2025, 11, 18, 10, 15),
          note: 'Our team will call you on 20 Nov at 1:39 PM.',
        ),
      ],
    ),
    Ticket(
      id: 'INQ-3529',
      subject: 'Welcome call',
      category: 'Account',
      status: TicketStatus.resolved,
      createdAt: DateTime(2025, 11, 13, 9, 0),
      followUpAt: DateTime(2025, 11, 16, 15, 57),
      description: 'Courtesy call after installation.',
      events: [
        TicketEvent(title: 'Ticket opened', at: DateTime(2025, 11, 13, 9, 0)),
        TicketEvent(title: 'Call completed', at: DateTime(2025, 11, 16, 15, 57)),
        TicketEvent(title: 'Resolved', at: DateTime(2025, 11, 16, 16, 2)),
      ],
    ),
  ];
}
