# Clear existing FAQs
Faq.destroy_all

faqs = [
  # Orders & Shipping
  {
    category: "Orders & Shipping",
    question: "How can I track my order?",
    answer: "Once your order is shipped, you'll receive a tracking number via email. You can also find your tracking information by logging into your account and viewing your order history.",
  },
  {
    category: "Orders & Shipping",
    question: "How long does shipping take?",
    answer: "Standard shipping typically takes 3-5 business days within the continental US. International shipping can take 7-14 business days depending on the destination.",
  },
  {
    category: "Orders & Shipping",
    question: "Do you offer international shipping?",
    answer: "Yes, we offer worldwide shipping! Shipping costs and delivery times vary by location. You can see exact shipping costs at checkout.",
  },

  # Returns & Refunds
  {
    category: "Returns & Refunds",
    question: "What is your return policy?",
    answer: "We offer a 30-day return policy for unused items in their original packaging. Simply initiate a return through your account or contact our customer service team.",
  },
  {
    category: "Returns & Refunds",
    question: "How do I return an item?",
    answer: "To return an item: 1) Log into your account, 2) Find the order and select 'Return Item', 3) Follow the instructions to print your return label, 4) Pack the item securely and attach the label.",
  },
  {
    category: "Returns & Refunds",
    question: "When will I receive my refund?",
    answer: "Refunds are processed within 3-5 business days after we receive your return. The funds may take an additional 2-5 business days to appear in your account, depending on your bank.",
  },

  # Product Information
  {
    category: "Product Information",
    question: "Are your products authentic?",
    answer: "Yes, all our products are 100% authentic and sourced directly from authorized manufacturers or distributors. We guarantee the authenticity of every item we sell.",
  },
  {
    category: "Product Information",
    question: "What if an item is out of stock?",
    answer: "You can sign up for email notifications on the product page to be alerted when the item is back in stock. We typically restock popular items within 2-4 weeks.",
  },
  {
    category: "Product Information",
    question: "Can I modify my order after placing it?",
    answer: "Orders can be modified within 1 hour of placement. After that, we begin processing orders for shipment and cannot make changes. Please contact customer service for assistance.",
  },

  # Account & Payment
  {
    category: "Account & Payment",
    question: "What payment methods do you accept?",
    answer: "We accept all major credit cards (Visa, MasterCard, American Express), PayPal, and Apple Pay. All payments are processed securely through our encrypted payment system.",
  },
  {
    category: "Account & Payment",
    question: "Is it safe to save my payment information?",
    answer: "Yes, our website uses industry-standard encryption to protect your payment information. We never store complete credit card numbers on our servers.",
  },
  {
    category: "Account & Payment",
    question: "How do I create an account?",
    answer: "Click the 'Account' icon in the top right corner and select 'Create Account'. Fill in your email, create a password, and provide basic information to complete registration.",
  },

  # Technical Support
  {
    category: "Technical Support",
    question: "What should I do if I can't log in?",
    answer: "First, try resetting your password using the 'Forgot Password' link. If that doesn't work, clear your browser cache and cookies. Still having trouble? Contact our support team.",
  },
  {
    category: "Technical Support",
    question: "How do I update my email preferences?",
    answer: "Log into your account, go to 'Account Settings', then 'Email Preferences'. Here you can choose which types of emails you'd like to receive or unsubscribe from all marketing emails.",
  },
  {
    category: "Technical Support",
    question: "Is your website secure?",
    answer: "Yes, our website uses SSL encryption to protect your personal and payment information. We regularly update our security measures to ensure your data remains safe.",
  },
]

# Create FAQs
faqs.each do |faq|
  Faq.create!(faq)
end

puts "Created #{Faq.count} FAQs"
