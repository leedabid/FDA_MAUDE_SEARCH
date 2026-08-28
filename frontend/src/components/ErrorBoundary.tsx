import React, { Component, ErrorInfo, ReactNode } from "react";
import { AlertTriangle, RefreshCw } from "lucide-react";

interface Props {
  children: ReactNode;
  tabName?: string;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  public state: State = {
    hasError: false,
    error: null,
  };

  public static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  public componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error("Uncaught tab error:", error, errorInfo);
  }

  public render() {
    if (this.state.hasError) {
      return (
        <div className="flex flex-col items-center justify-center p-12 bg-slate-900/80 border border-red-500/30 rounded-2xl backdrop-blur-md text-center max-w-lg mx-auto my-12">
          <div className="p-3 bg-red-500/10 text-red-400 border border-red-500/20 rounded-2xl mb-4">
            <AlertTriangle className="w-8 h-8" />
          </div>
          <h3 className="text-base font-bold text-white mb-1">
            {this.props.tabName || "화면"} 데이터를 표시하는 중 오류가 발생했습니다
          </h3>
          <p className="text-xs text-slate-400 mb-6">
            {this.state.error?.message || "알 수 없는 렌더링 오류가 발생했습니다."}
          </p>
          <button
            type="button"
            onClick={() => {
              this.setState({ hasError: false, error: null });
              window.location.reload();
            }}
            className="flex items-center gap-2 px-4 py-2 bg-indigo-600 hover:bg-indigo-500 text-white rounded-xl text-xs font-semibold shadow-lg shadow-indigo-600/30 transition"
          >
            <RefreshCw className="w-3.5 h-3.5" />
            <span>새로고침 및 다시 시도</span>
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}
