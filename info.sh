#!/bin/bash

# ============================================================
#  EKS Cluster Status Dashboard
#  Author: Veera Maddula
#  Cluster: demo-eks-cluster | us-west-2
# ============================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Divider
divider() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Section header
header() {
    echo ""
    divider
    echo -e "${BOLD}${CYAN}  $1${NC}"
    divider
}

# ── BANNER ────────────────────────────────────────────────────
clear
echo -e "${BOLD}${PURPLE}"
echo "  ╔═══════════════════════════════════════════════════════════╗"
echo "  ║         ☸  EKS CLUSTER STATUS DASHBOARD                  ║"
echo "  ║         Veera Maddula | demo-eks-cluster | us-west-2     ║"
echo "  ╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  ${YELLOW}Generated:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ── CLUSTER INFO ──────────────────────────────────────────────
header "1. CLUSTER INFO"
kubectl cluster-info 2>/dev/null || echo -e "${RED}  ✗ Cannot connect to cluster${NC}"

# ── NODES ─────────────────────────────────────────────────────
header "2. NODES"
NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
READY_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | grep -c "Ready")
echo -e "  ${WHITE}Total Nodes:${NC} ${NODE_COUNT}  |  ${GREEN}Ready: ${READY_COUNT}${NC}"
echo ""
kubectl get nodes -o wide 2>/dev/null

# Node resource allocation
echo ""
echo -e "  ${YELLOW}▶ Node Resource Allocation:${NC}"
kubectl describe nodes 2>/dev/null | grep -A 6 "Allocated resources" | grep -E "cpu|memory|Allocated"

# ── NAMESPACES ────────────────────────────────────────────────
header "3. NAMESPACES"
NS_COUNT=$(kubectl get namespaces --no-headers 2>/dev/null | wc -l)
echo -e "  ${WHITE}Total Namespaces:${NC} ${NS_COUNT}"
echo ""
kubectl get namespaces 2>/dev/null

# ── PODS SUMMARY ──────────────────────────────────────────────
header "4. PODS SUMMARY (ALL NAMESPACES)"
TOTAL_PODS=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | wc -l)
RUNNING_PODS=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | grep -c "Running")
PENDING_PODS=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | grep -c "Pending")
FAILED_PODS=$(kubectl get pods --all-namespaces --no-headers 2>/dev/null | grep -c "Error\|CrashLoopBackOff\|Failed")

echo -e "  ${WHITE}Total Pods:${NC}   ${TOTAL_PODS}"
echo -e "  ${GREEN}✔ Running:${NC}    ${RUNNING_PODS}"
echo -e "  ${YELLOW}⚠ Pending:${NC}    ${PENDING_PODS}"
echo -e "  ${RED}✗ Failed:${NC}     ${FAILED_PODS}"
echo ""
kubectl get pods --all-namespaces -o wide 2>/dev/null

# ── DEV NAMESPACE ─────────────────────────────────────────────
header "5. DEV NAMESPACE (service-a & service-b)"
echo -e "  ${YELLOW}▶ Pods:${NC}"
kubectl get pods -n dev -o wide 2>/dev/null || echo -e "  ${RED}  No resources found in dev namespace${NC}"
echo ""
echo -e "  ${YELLOW}▶ Services:${NC}"
kubectl get svc -n dev 2>/dev/null || echo -e "  ${RED}  No services found${NC}"
echo ""
echo -e "  ${YELLOW}▶ Deployments:${NC}"
kubectl get deployments -n dev 2>/dev/null || echo -e "  ${RED}  No deployments found${NC}"

# ── MONITORING NAMESPACE ──────────────────────────────────────
header "6. MONITORING NAMESPACE (Prometheus + Grafana + AlertManager)"
echo -e "  ${YELLOW}▶ Pods:${NC}"
kubectl get pods -n monitoring -o wide 2>/dev/null || echo -e "  ${RED}  No resources found in monitoring namespace${NC}"
echo ""
echo -e "  ${YELLOW}▶ Services & Ports:${NC}"
kubectl get svc -n monitoring 2>/dev/null
echo ""
echo -e "  ${YELLOW}▶ Access URLs (port-forward must be running):${NC}"
echo -e "  ${GREEN}  Grafana      →  http://$(curl -s ifconfig.me 2>/dev/null || echo '<ec2-ip>'):3000${NC}"
echo -e "  ${GREEN}  Prometheus   →  http://$(curl -s ifconfig.me 2>/dev/null || echo '<ec2-ip>'):9091${NC}"
echo -e "  ${GREEN}  AlertManager →  http://$(curl -s ifconfig.me 2>/dev/null || echo '<ec2-ip>'):9093${NC}"

# ── OTEL DEMO NAMESPACE ───────────────────────────────────────
header "7. OTEL DEMO NAMESPACE (Astronomy Shop)"
kubectl get pods -n otel-demo -o wide 2>/dev/null || echo -e "  ${RED}  No resources found in otel-demo namespace${NC}"

# ── DEFAULT NAMESPACE ─────────────────────────────────────────
header "8. DEFAULT NAMESPACE"
kubectl get pods -n default -o wide 2>/dev/null || echo -e "  ${RED}  No resources found in default namespace${NC}"

# ── SERVICES SUMMARY ──────────────────────────────────────────
header "9. ALL SERVICES (ALL NAMESPACES)"
TOTAL_SVC=$(kubectl get svc --all-namespaces --no-headers 2>/dev/null | wc -l)
LB_SVC=$(kubectl get svc --all-namespaces --no-headers 2>/dev/null | grep -c "LoadBalancer")
CLUSTER_SVC=$(kubectl get svc --all-namespaces --no-headers 2>/dev/null | grep -c "ClusterIP")
echo -e "  ${WHITE}Total Services:${NC}      ${TOTAL_SVC}"
echo -e "  ${GREEN}LoadBalancer:${NC}        ${LB_SVC}"
echo -e "  ${CYAN}ClusterIP:${NC}           ${CLUSTER_SVC}"
echo ""
kubectl get svc --all-namespaces 2>/dev/null

# ── DEPLOYMENTS ───────────────────────────────────────────────
header "10. ALL DEPLOYMENTS (ALL NAMESPACES)"
TOTAL_DEPLOY=$(kubectl get deployments --all-namespaces --no-headers 2>/dev/null | wc -l)
echo -e "  ${WHITE}Total Deployments:${NC} ${TOTAL_DEPLOY}"
echo ""
kubectl get deployments --all-namespaces 2>/dev/null

# ── SERVICEMONITORS ───────────────────────────────────────────
header "11. SERVICEMONITORS & ALERTS"
echo -e "  ${YELLOW}▶ ServiceMonitors:${NC}"
kubectl get servicemonitor --all-namespaces 2>/dev/null || echo -e "  ${RED}  None found${NC}"
echo ""
echo -e "  ${YELLOW}▶ PrometheusRules:${NC}"
kubectl get prometheusrule --all-namespaces 2>/dev/null || echo -e "  ${RED}  None found${NC}"
echo ""
echo -e "  ${YELLOW}▶ AlertmanagerConfig:${NC}"
kubectl get alertmanagerconfig --all-namespaces 2>/dev/null || echo -e "  ${RED}  None found${NC}"

# ── PORT FORWARDS ─────────────────────────────────────────────
header "12. PORT-FORWARD STATUS"
PF_COUNT=$(ps aux | grep "kubectl port-forward" | grep -v grep | wc -l)
if [ "$PF_COUNT" -gt 0 ]; then
    echo -e "  ${GREEN}✔ Port-forwards running: ${PF_COUNT}${NC}"
    ps aux | grep "kubectl port-forward" | grep -v grep | awk '{print "  →", $11, $12, $13, $14}'
else
    echo -e "  ${RED}✗ No port-forwards running!${NC}"
    echo -e "  ${YELLOW}  Run these to start:${NC}"
    echo -e "  nohup kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80 --address 0.0.0.0 > /dev/null 2>&1 &"
    echo -e "  nohup kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9091:9090 --address 0.0.0.0 > /dev/null 2>&1 &"
    echo -e "  nohup kubectl port-forward svc/prometheus-kube-prometheus-alertmanager -n monitoring 9093:9093 --address 0.0.0.0 > /dev/null 2>&1 &"
fi

# ── INGRESS ───────────────────────────────────────────────────
header "13. INGRESS / LOAD BALANCERS"
kubectl get ingress --all-namespaces 2>/dev/null || echo -e "  ${RED}  No ingress found${NC}"

# ── HELM RELEASES ─────────────────────────────────────────────
header "14. HELM RELEASES"
helm list --all-namespaces 2>/dev/null || echo -e "  ${RED}  Helm not installed or no releases${NC}"

# ── FOOTER ────────────────────────────────────────────────────
echo ""
divider
echo -e "${BOLD}${PURPLE}  ✅ EKS Cluster Status Report Complete!${NC}"
echo -e "  ${YELLOW}Cluster:${NC} demo-eks-cluster | ${YELLOW}Region:${NC} us-west-2"
echo -e "  ${YELLOW}Terraform State:${NC} s3://demo-terraform-eks-state-bucket-veeradurga"
divider
echo ""
